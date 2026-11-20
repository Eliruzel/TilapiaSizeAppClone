# Export the trained Tilapia detector for Android

Android cannot load the training checkpoint `detect/tilapia_detection-2/weights/best.pt` directly. Export it to a LiteRT/TFLite model, then add the result to the Flutter assets.

## Convert it in Google Colab

1. Open a new notebook at [Google Colab](https://colab.research.google.com/).
2. Run this cell and upload `best.pt` from `backend/detect/tilapia_detection-2/weights/`:

```python
!pip install -q ultralytics==8.4.215
from google.colab import files
uploaded = files.upload()
checkpoint = next(name for name in uploaded if name.endswith('.pt'))
```

3. Run this next cell to export a 640px detection model without embedded NMS (the Android runtime handles NMS):

```python
from ultralytics import YOLO
model = YOLO(checkpoint)
exported_path = model.export(format='litert', imgsz=640, nms=None)
print(exported_path)
```

4. Download the `.tflite` file returned by the export. If Colab does not automatically download it, run:

```python
files.download(str(exported_path))
```

5. Copy the downloaded model to:

```text
frontend/tilapiasizeclone/assets/models/tilapia_detector.tflite
```

The Flutter app already includes `assets/models/` as an asset directory. Then run the app on an Android device and open **Live Camera**. The camera view should show the detector's boxes and Tilapia confidence, and **Use photo** returns a frame with the detection overlay.

This export uses the existing trained checkpoint; it does not train or validate it again. Model quality still depends on your dataset and evaluation results.
