import cv2
import torch
import numpy as np
from facenet_pytorch import MTCNN


class FaceDetector(object):
    def __init__(self):
        """
        Setup the common objects to store history of each position coordinates
        """
        self.historyX1 = []
        self.historyX2 = []
        self.historyY = []
        self.historyZ = []
        self.historyX1Copy = []
        self.maxLength = 5

    def _draw_human_face(self, frame, boxes, probs, landmarks):
        try:
            for box, prob, ld in zip(boxes, probs, landmarks):
                cv2.rectangle(frame, (box[0], box[1]), (box[2], box[3]), (0, 0, 255), thickness=2)
        except:
            pass
        return frame

    def _draw_robot_face_background(self, x1, img):
        """
        Draw a dynamic face whose shape is changed by human's face motion. When human's face is at the center
        position, the robot face will be presented as a complete circle. As the human's face move to left or right,
        the robot face will be presented as an ellipse accordingly.
        :param x1: The received left eyeball's parameter. We will use it to calculate the width of robot face.
        :param img: The painting image.
        """
        x1_copy = x1
        if x1_copy >= 530: x1_copy = 530 - (x1_copy - 530)
        if x1_copy <= 400: x1_copy = 400
        self.historyX1Copy.append(x1_copy)
        if len(self.historyX1Copy) > self.maxLength:
            self.historyX1Copy.pop(0)
        x1_copy = int(np.mean(self.historyX1Copy))
        img = cv2.ellipse(img, (1300, 800), (x1_copy, 530), 0, 0, 360, (0, 255, 255), -1)
        # img = cv2.circle(img, (1300, 800), 530, (0, 255, 255), -1)

    def _draw_robot_eyes(self, z, img):
        """
        Draw robot eyes rim. As the human face moves close to the camera, the robot eyes rims become larger.
        Vice versa.
        :param z: The human face width
        :param img: The painting image.
        :return: Modified z (the robot eyes rims diameter).
        """
        # Setup the the upper bound and lower bound of the eyes rim size
        z = z - 190
        if z >= 120: z = 120
        if z <= 90: z = 90
        self.historyZ.append(z)
        if len(self.historyZ) > self.maxLength:
            self.historyZ.pop(0)
        z = int(np.mean(self.historyZ))
        img = cv2.circle(img, (1050, 600), z, (255, 255, 255), -1)
        img = cv2.circle(img, (1550, 600), z, (255, 255, 255), -1)
        return z

    def _update_coordinates(self, dataToUpdate, origin, bound):
        '''
        Adjust the positions of the eyeballs to adapt to the boundary of the eyes rim both horizontally and vertically
        :param dataToUpdate: the coordinate needed to be updated
        :param origin: the center coordinate of the eye socket
        :param bound: the boundary coordinate of the eye socket
        :return: the coordinate being updated
        '''
        if dataToUpdate - origin >= bound:
            dataToUpdate = origin + bound
        if origin - dataToUpdate >= bound:
            dataToUpdate = origin - bound
        return dataToUpdate

    def _micro_update_coordinates(self, x1, x2, y, diag, xOrigin1, xOrigin2, yOrigin):
        '''
        Adjust the positions of the eyeballs to adapt to the boundary of the eyes rim after introducing the
        diagonal direction boundary
        :param x1: x1 coordinate
        :param x2: x2 coordinate
        :param y: y coordinate
        :param diag: diagonal distance
        :param xOrigin1: the x center coordinate of the left eye socket
        :param xOrigin2: the x center coordinate of the right eye socket
        :param yOrigin: the y center coordinate of the eyes socket
        :return: x1, x2, y
        '''
        if x1 >= xOrigin1 + diag and x2 >= xOrigin2 + diag and y >= yOrigin + diag:
            x1 = xOrigin1 + diag
            x2 = xOrigin2 + diag
            y = yOrigin + diag
        if x1 >= xOrigin1 + diag and x2 >= xOrigin2 + diag and y <= yOrigin - diag:
            x1 = xOrigin1 + diag
            x2 = xOrigin2 + diag
            y = yOrigin - diag
        if x1 <= xOrigin1 - diag and x2 <= xOrigin2 - diag and y >= yOrigin + diag:
            x1 = xOrigin1 - diag
            x2 = xOrigin2 - diag
            y = yOrigin + diag
        if x1 <= xOrigin1 - diag and x2 <= xOrigin2 - diag and y <= yOrigin - diag:
            x1 = xOrigin1 - diag
            x2 = xOrigin2 - diag
            y = yOrigin - diag
        return x1, x2, y

    def _draw_robot_eyeballs(self, x1, y, z, img):
        """
        Draw the robot dynamic eyeballs. The eyeballs would move accordingly by the human face motion.
        :param x1: The coordinate of the upper-left point of human's face
        :param y: The height of human's face
        :param z: The width of human's face
        :param img: The painting image.
        """
        # Initialize the horizontal and vertical coordinates of the eyeballs center
        x1 += 520
        x2 = x1 + 500
        y += 130

        
        # Adjust the positions of the eyeballs to adapt to the boundary of the eyes rim
        # x1 = self._update_coordinates(x1, 1050, z - 30)
        # x2 = self._update_coordinates(x2, 1550, z - 30)
        x1 = self._update_coordinates(1050 - (x1 - 1050), 1050, z - 30)
        x2 = self._update_coordinates(1550 - (x2 - 1550), 1550, z - 30)

        y = self._update_coordinates(y, 600, z - 30)
        # Calculate the boundary toward the diagonal direction
        diag = int((z - 30) / np.sqrt(2))
        x1, x2, y = self._micro_update_coordinates(x1, x2, y, diag, 1050, 1550, 600)
        # Store the last five historic values of x1, x2, and y and use their average values respectively.
        self.historyX1.append(x1)
        self.historyX2.append(x2)
        self.historyY.append(y)
        if len(self.historyX1) > self.maxLength:
            self.historyX1.pop(0)
        if len(self.historyX2) > self.maxLength:
            self.historyX2.pop(0)
        if len(self.historyY) > self.maxLength:
            self.historyY.pop(0)
        x1 = int(np.mean(self.historyX1))
        x2 = int(np.mean(self.historyX2))
        y = int(np.mean(self.historyY))
        # Draw the two eyeballs
        cv2.circle(img, (x1, y), 30, (0, 0, 0), -1)
        cv2.circle(img, (x2, y), 30, (0, 0, 0), -1)

    def _draw_robot_face(self, x1, y, z):
        """
        Draw the robot face, eyes rim, mouth, and eyeballs respectively
        :param x1: The coordinate of the upper-left point of human's face
        :param y: The height of human's face
        :param z: The width of human's face
        """
        # Setup the painting background
        img = np.zeros((1600, 2600, 3), np.uint8)
        img[:] = (255, 255, 255)

        # Draw robot face background
        self._draw_robot_face_background(x1, img)

        # Draw robot eyes rims
        z = self._draw_robot_eyes(z, img)

        # Draw robot mouth
        img = cv2.line(img, (1000, 1000), (1600, 1000), (0, 0, 0), 2)

        # Draw robot dynamic eyeballs
        self._draw_robot_eyeballs(x1, y, z, img)

        cv2.imshow('image', img)
        cv2.waitKey(1)

    def run(self):
        """
        Draw the camera realtime photo and the corresponding robot face
        """
        cap = cv2.VideoCapture(0)
        while True:
            ret, frame = cap.read()
            try:
                boxes, probs, landmarks = MTCNN().detect(frame, landmarks=True)
                self._draw_human_face(frame, boxes, probs, landmarks)
                # x = (boxes[0][0] + boxes[0][2]) / 2
                y = (boxes[0][1] + boxes[0][3]) / 2
                z = boxes[0][2] - boxes[0][0]
                self._draw_robot_face(int(boxes[0][0]), int(y), int(z))
            except:
                pass
            cv2.imshow('Face Detection', frame)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
        cap.release()
        cv2.destroyAllWindows()



fcd = FaceDetector()
fcd.run()