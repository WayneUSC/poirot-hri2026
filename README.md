# POIROT HRI 2026 Reproducibility Package

This repository contains technical materials for reproducing the robot-side interaction system and experimental workflow described in:

**POIROT: Investigating Direct Tangible vs. Digitally Mediated Interaction and Attitude Moderation in Multi-party Murder Mystery Games**  
Wen Chen et al., HRI 2026.

The package focuses on reproducibility of the robot platform, companion app, tangible clue delivery, gaze display, voice interaction architecture, and study procedure. It intentionally excludes private credentials, participant data, travel/admin files, raw videos, and third-party dependency folders.

## Repository Layout

```text
android-script-distributor/   Android companion app for room setup, role selection, scripts, and clues
ios-script-distributor/       iOS companion app actually used in the HRI study
ios-gaze-display/             iPhone-based gaze and blinking display used as POIROT's face
face-tracking/                Python prototypes for face tracking and robot-eye rendering
hardware/clue-dispenser/      BOM and implementation notes for the card dispenser
matlab-simulation/            RRT/tabletop navigation and clue-delivery animation demos
experiment-materials/         Protocols and questionnaire summaries
docs/figures/                 Appendix figures and UI/hardware screenshots
paper/                        Camera-ready paper, appendix, and source text
```

## What Is Included

- iOS app source actually used for the study's script/clue distribution workflow.
- Android app source retained as a later/parallel reference implementation.
- iOS gaze-display app using Apple Vision face landmarks, smoothing, and randomized blinking.
- Python face-tracking prototypes based on OpenCV and MTCNN/facenet-pytorch.
- MATLAB simulations for tabletop clue delivery and RRT-Connect path planning.
- Clue-card dispenser technical description and bill of materials.
- Appendix figures from the HRI paper.
- Paper and appendix PDFs for reference.

## What You Need To Provide

Some assets are intentionally represented by placeholders:

- `ios-script-distributor/Scripts Distributor/GoogleService-Info.plist`: create this from your own Firebase project.
- `android-script-distributor/app/google-services.json`: create this only if you want to run the Android reference implementation.
- Role-script PDFs and clue-card images: replace the placeholder URLs in `app/src/main/assets/Scripts/*.json`.
- Full robot CAD source: the local project currently contains photos and appendix diagrams, but not the final POIROT shell CAD/STL.
- Voice-agent deployment: this repository documents the Xiaozhi/ESP32-S3 pipeline, but does not include private model/provider credentials.

## Quick Start

1. Clone this repository.
2. Read `docs/reproduction-guide.md` for the full system setup.
3. Configure Firebase for the iOS script distributor using `ios-script-distributor/Scripts Distributor/GoogleService-Info.plist.example`.
4. Run `pod install` in `ios-script-distributor/`, then open `Scripts Distributor.xcworkspace`.
5. Open `ios-gaze-display/EyeTrackingApp.xcodeproj` in Xcode and run it on an iPhone with a front camera.
6. Build the card dispenser following `hardware/clue-dispenser/README.md`.
7. Run the study using `experiment-materials/experimental-protocol.md`.

## Citation

If you use these materials, please cite the HRI 2026 paper:

```bibtex
@inproceedings{chen2026poirot,
  title = {POIROT: Investigating Direct Tangible vs. Digitally Mediated Interaction and Attitude Moderation in Multi-party Murder Mystery Games},
  author = {Chen, Wen and Chen, Rongxi and Chen, Shankai and Gong, Huiyang and Guo, Minghui and Xu, Yingri and Wu, Xintong and Fu, Xinyi},
  booktitle = {Proceedings of the 21st ACM/IEEE International Conference on Human-Robot Interaction},
  year = {2026},
  doi = {10.1145/3757279.3788663}
}
```

## License

Code and technical documentation are prepared for academic reproducibility. Before public release, choose a license such as MIT, BSD-3-Clause, or Apache-2.0, and confirm that all included images/game materials can be redistributed.
