from ultralytics import YOLO

# Load YOLOv8 nano model
model = YOLO("yolov8n.pt")

# continue nako ni mga 90
# model = YOLO("runs/detect/tilapia_detection/weights/last.pt")

model.train(
    data="dataset/data.yaml",
    epochs=10,
    imgsz=640,
    batch=8,
    name="tilapia_detection"
)
