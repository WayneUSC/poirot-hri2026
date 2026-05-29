# Face Tracking Prototypes

This folder contains Python prototypes used while developing robot gaze behavior.

## Files

- `eyeball.py`: webcam face detection and robot-eye rendering.
- `face_tracking_offline_demo.py`: offline MTCNN face-box tracking over a video.
- `detector.py`: additional local detector prototype from the development folder.

## Suggested Environment

```bash
python -m venv .venv
source .venv/bin/activate
pip install opencv-python numpy pillow torch facenet-pytorch mmcv
```

`mmcv` installation can vary by platform and CUDA version. If installation is difficult, use `eyeball.py` first because it mainly depends on OpenCV, NumPy, PyTorch, and facenet-pytorch.

## Run

```bash
python eyeball.py
```

Press `q` in the OpenCV window to exit.

These scripts are prototypes; the paper's study-facing gaze display is the Swift/iOS implementation in `ios-gaze-display/`.
