package com.example.mountain_app;

import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.content.Context;
import android.opengl.Matrix;
import android.util.Log;

import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Arrays;

import static android.hardware.SensorManager.*;
import static android.view.Surface.*;
import static android.view.Surface.ROTATION_180;
import static android.view.Surface.ROTATION_270;

public class MainActivity extends FlutterActivity implements SensorEventListener {
  private float[] orientedRotationMatrix = new float[16];
  private float[] cameraProjectionMatrix = new float[16];
  private float[] rotatedProjectionMatrix = new float[16];
  private final static float Z_NEAR = 0.5f;
  private final static float Z_FAR = 10000;
  double latitude;
  double longitude;
  double altitude;
  float x, y;
  int width, height;
  float[] pixelcoords = new float[2];
  List<Float> intrinsicParamsList = new ArrayList<Float>();
  private ArrayList<ARPoint> arPoints = new ArrayList<>();
  private ArrayList<Point> pixelPoints;

  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    final String CHANNEL = "com.example.mountain_app/focalLength";
    GeneratedPluginRegistrant.registerWith(getFlutterEngine());
    new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
        (call, result) -> {
          if (call.method.equals("debugger")) {
            debugger();
            result.success("");
          } else if (call.method.equals("startSensor")) {
            startSensor();
            result.success("");
          } else if (call.method.equals("getOrientedRotationMatrix")) {
            result.success(getOrientedRotationMatrix());
          } else if (call.method.equals("sendLocation")) {
            latitude = call.argument("latitude");
            longitude = call.argument("longitude");
            altitude = call.argument("altitude");
            width = call.argument("width");
            height = call.argument("height");
            result.success("Implemented");
          } else if (call.method.equals("getLatitude")) {
            result.success(getLatitude());
          } else if (call.method.equals("getCameraIntrinsicParams")) {
            String cameraId = call.argument("cameraId");
            float[] intrinsicParams = getCameraIntrinsicParams(cameraId);

            for (float value : intrinsicParams) {
              intrinsicParamsList.add(value);
            }
            cameraProjectionMatrix = getCameraProjectionMatrix(intrinsicParamsList);
            // drawPoint(latitude, longitude, altitude, cameraProjectionMatrix, x, y);
            result.success(intrinsicParamsList);
          } else if (call.method.equals("getPixelCoords")) {
            result.success(getPixelCoords());
          } else if (call.method.equals("sendPointstoDart")) {
            ArrayList<Point> pixelPoints = getPixelPoints();
            ArrayList<Map<String, Object>> pointList = sendPointsToDart(pixelPoints);
            result.success(pointList);
          } else if (call.method.equals("getPixelPoints")) {
            result.success(getPixelPoints());
          } else if (call.method.equals("sendPeaksData")) {
            List<Map<String, Object>> peaksData = (List<Map<String, Object>>) call.arguments;

            for (Map<String, Object> peakData : peaksData) {
              String name = (String) peakData.get("name");
              double lat = (double) peakData.get("lat");
              double lon = (double) peakData.get("lon");
              int alt = (int) peakData.get("alt");

              ARPoint arPoint = new ARPoint(name, lat, lon, alt);
              arPoints.add(arPoint);
            }
          } else
            result.notImplemented();
        });

    cameraProjectionMatrix[0] = 2730.72900390625f / 2000.0f;
    cameraProjectionMatrix[1] = 0.0f;
    cameraProjectionMatrix[2] = 0.0f;
    cameraProjectionMatrix[3] = 0.0f;
    cameraProjectionMatrix[4] = 0.0f;
    cameraProjectionMatrix[5] = 2730.7294921875f / 1500.0f;
    cameraProjectionMatrix[6] = 0.0f;
    cameraProjectionMatrix[7] = 0.0f;
    cameraProjectionMatrix[8] = 0.0f;
    cameraProjectionMatrix[9] = 0.0f;
    cameraProjectionMatrix[10] = (-(Z_FAR + Z_NEAR)) / Z_FAR - Z_NEAR;
    cameraProjectionMatrix[11] = (-2 * Z_FAR * Z_NEAR) / Z_FAR - Z_NEAR;
    cameraProjectionMatrix[12] = 0.0f;
    cameraProjectionMatrix[13] = 0.0f;
    cameraProjectionMatrix[14] = -1.0f;
    cameraProjectionMatrix[15] = 0.0f;

      pixelPoints = new ArrayList<Point>() {
      {
        add(new Point("", 0, 0, 0,0));
        add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));

      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      

      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));
      add(new Point("", 0, 0, 0,0));

      }
      };
     

  }

  private float[] getCameraProjectionMatrix(List<Float> intrinsicParams) {
    float[] cameraProjectionMatrix = new float[16];
    if (!intrinsicParams.isEmpty()) {
      float fx = intrinsicParams.get(0);
      float fy = intrinsicParams.get(1);
      float cx = intrinsicParams.get(2);
      float cy = intrinsicParams.get(3);
      float skew = intrinsicParams.get(4);

      cameraProjectionMatrix[0] = fx / cx;
      cameraProjectionMatrix[1] = 0.0f;
      cameraProjectionMatrix[2] = 0.0f;
      cameraProjectionMatrix[3] = 0.0f;
      cameraProjectionMatrix[4] = 0.0f;
      cameraProjectionMatrix[5] = fy / cy;
      cameraProjectionMatrix[6] = 0.0f;
      cameraProjectionMatrix[7] = 0.0f;
      cameraProjectionMatrix[8] = 0.0f;
      cameraProjectionMatrix[9] = 0.0f;
      cameraProjectionMatrix[10] = (-(Z_FAR + Z_NEAR)) / Z_FAR - Z_NEAR;
      cameraProjectionMatrix[11] = (-2 * Z_FAR * Z_NEAR) / Z_FAR - Z_NEAR;
      cameraProjectionMatrix[12] = 0.0f;
      cameraProjectionMatrix[13] = 0.0f;
      cameraProjectionMatrix[14] = -1.0f;
      cameraProjectionMatrix[15] = 0.0f;
    }
    cameraProjectionMatrix[0] = 2730.72900390625f / 2000.0f;
    cameraProjectionMatrix[1] = 0.0f;
    cameraProjectionMatrix[2] = 0.0f;
    cameraProjectionMatrix[3] = 0.0f;
    cameraProjectionMatrix[4] = 0.0f;
    cameraProjectionMatrix[5] = 2730.7294921875f / 1500.0f;
    cameraProjectionMatrix[6] = 0.0f;
    cameraProjectionMatrix[7] = 0.0f;
    cameraProjectionMatrix[8] = 0.0f;
    cameraProjectionMatrix[9] = 0.0f;
    cameraProjectionMatrix[10] = (-(Z_FAR + Z_NEAR)) / Z_FAR - Z_NEAR;
    cameraProjectionMatrix[11] = (-2 * Z_FAR * Z_NEAR) / Z_FAR - Z_NEAR;
    cameraProjectionMatrix[12] = 0.0f;
    cameraProjectionMatrix[13] = 0.0f;
    cameraProjectionMatrix[14] = -1.0f;
    cameraProjectionMatrix[15] = 0.0f;

    debugger();
    return cameraProjectionMatrix;
  }

  public float[] getCameraIntrinsicParams(String cameraId) {
    float[] intrinsicParams = new float[5];
    // Retrieve CameraManager instance
    CameraManager cameraManager = (CameraManager) getSystemService(Context.CAMERA_SERVICE);
    try {
      // Retrieve CameraCharacteristics object for the specified camera device
      CameraCharacteristics cameraCharacteristics = cameraManager.getCameraCharacteristics(cameraId);
      // Retrieve intrinsic calibration parameters from LENS_INTRINSIC_CALIBRATION key
      CameraCharacteristics.Key<float[]> intrinsicKey = CameraCharacteristics.LENS_INTRINSIC_CALIBRATION;
      intrinsicParams = cameraCharacteristics.get(intrinsicKey);
    } catch (CameraAccessException e) {
      // Log.e(TAG, "Failed to obtain intrinsic calibration parameters", e);
    }
    return intrinsicParams;
  }

  public void startSensor() {
    SensorManager sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
    Sensor sensor = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);
    
    sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_NORMAL);
  }

  @Override
  public void onSensorChanged(SensorEvent sensorEvent) {
    rotatedProjectionMatrix = updateOrientation(sensorEvent.values, cameraProjectionMatrix);
    Log.i("MainActivity", "pixel point size is: " + Arrays.toString(sensorEvent.values));
    pixelcoords = drawPoint(latitude, longitude, altitude, rotatedProjectionMatrix, arPoints, x, y, pixelPoints, width,
        height);
  }

  @Override
  public void onAccuracyChanged(Sensor sensor, int accuracy) {
    if (accuracy == SensorManager.SENSOR_STATUS_UNRELIABLE) {
      Log.w("DeviceOrientation", "Orientation compass unreliable");
    }
  }

  private float[] updateOrientation(float[] rotationVector, float[] cameraProjectionMatrix) {
    float[] rotationMatrix = new float[16];
    getRotationMatrixFromVector(rotationMatrix, rotationVector);
    final int screenRotation = this.getWindowManager().getDefaultDisplay()
        .getRotation();

    switch (screenRotation) {
      case ROTATION_90:
        remapCoordinateSystem(rotationMatrix,
            AXIS_Y,
            AXIS_MINUS_X, orientedRotationMatrix);
        break;
      case ROTATION_270:
        remapCoordinateSystem(rotationMatrix,
            AXIS_MINUS_Y,
            AXIS_X, orientedRotationMatrix);
        break;
      case ROTATION_180:
        remapCoordinateSystem(rotationMatrix,
            AXIS_MINUS_X, AXIS_MINUS_Y,
            orientedRotationMatrix);
        break;
      default:
        remapCoordinateSystem(rotationMatrix,
            AXIS_X, AXIS_Y,
            orientedRotationMatrix);
        break;
    }

    float[] rotatedProjectionMatrix = new float[16];
    Matrix.multiplyMM(rotatedProjectionMatrix, 0, cameraProjectionMatrix, 0, rotationMatrix, 0);

    return rotatedProjectionMatrix;
  }

  public double getLatitude() {
    return latitude;
  }

  public float[] getPixelCoords() {
    return pixelcoords;
  }

  public float[] getOrientedRotationMatrix() {
    return orientedRotationMatrix;
  }

  public ArrayList<Point> getPixelPoints() {
    return pixelPoints;
  }

  private ArrayList<Map<String, Object>> sendPointsToDart(ArrayList<Point> points) {
    ArrayList<Map<String, Object>> pointList = new ArrayList<>();
    for (Point point : points) {
      Map<String, Object> pointData = new HashMap<>();
      pointData.put("name", point.getName());
      pointData.put("x", point.getX());
      pointData.put("y", point.getY());
      pointData.put("dist", point.getDist());
      pointData.put("ele", point.getEle());
      pointList.add(pointData);
    }
    return pointList;
  }

  public void debugger() {

    Log.i("MainActivity", "pixel point size is: " + Arrays.toString(cameraProjectionMatrix));
  }

  private final static double WGS84_A = 6378137.0;
  private final static double WGS84_E2 = 0.00669437999014;

  public static float[] WSG84toECEF(double latitude, double longitude, double altitude) {

    double radLat = Math.toRadians(latitude);
    double radLon = Math.toRadians(longitude);

    float cosLat = (float) Math.cos(radLat);
    float sinLat = (float) Math.sin(radLat);
    float cosLon = (float) Math.cos(radLon);
    float sinLon = (float) Math.sin(radLon);

    float N = (float) (WGS84_A / Math.sqrt(1.0 - WGS84_E2 * sinLat * sinLat));

    float x = (float) ((N + altitude) * cosLat * cosLon);
    float y = (float) ((N + altitude) * cosLat * sinLon);
    float z = (float) ((N * (1.0 - WGS84_E2) + altitude) * sinLat);

    return new float[] { x, y, z };

  }

  public static float[] ECEFtoENU(double latitude, double longitude, double altitude, float[] ecefCurrentLocation,
      float[] ecefPOI) {
    double radLat = Math.toRadians(latitude);
    double radLon = Math.toRadians(longitude);

    float cosLat = (float) Math.cos(radLat);
    float sinLat = (float) Math.sin(radLat);
    float cosLon = (float) Math.cos(radLon);
    float sinLon = (float) Math.sin(radLon);

    float dx = ecefCurrentLocation[0] - ecefPOI[0];
    float dy = ecefCurrentLocation[1] - ecefPOI[1];
    float dz = ecefCurrentLocation[2] - ecefPOI[2];

    float east = -sinLon * dx + cosLon * dy;

    float north = -sinLat * cosLon * dx - sinLat * sinLon * dy + cosLat * dz;

    float up = cosLat * cosLon * dx + cosLat * sinLon * dy + sinLat * dz;

    return new float[] { east, north, up, 1 };
  }

  public final static double AVERAGE_RADIUS_OF_EARTH_KM = 6371;

  public static int calculateDistanceInKilometer(double userLat, double userLng,
      double poiLat, double poiLon) {

    double latDistance = Math.toRadians(userLat - poiLat);
    double lonDistance = Math.toRadians(userLng - poiLon);

    double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
        + Math.cos(Math.toRadians(userLat)) * Math.cos(Math.toRadians(poiLat))
            * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);

    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return (int) (Math.round(AVERAGE_RADIUS_OF_EARTH_KM * c));
  }

  public static float[] drawPoint(double latitude, double longitude, double altitude, float[] cameraProjectionMatrix,
      ArrayList<ARPoint> points, float x, float y, ArrayList<Point> pixelPoints, int width, int height) {

    for (int i = 0; i < points.size(); i++) {
      float[] currentLocationInECEF = WSG84toECEF(latitude, longitude, altitude);
      float[] pointInECEF = WSG84toECEF(points.get(i).getLat(), points.get(i).getLon(), points.get(i).getAlt());
      float[] pointInENU = ECEFtoENU(latitude, longitude, altitude, currentLocationInECEF, pointInECEF);
      float[] cameraCoordinateVector = new float[4];
      Matrix.multiplyMV(cameraCoordinateVector, 0, cameraProjectionMatrix, 0, pointInENU, 0);
      int distance = calculateDistanceInKilometer(latitude, longitude, points.get(i).getLat(), points.get(i).getLon());

      if (cameraCoordinateVector[2] < 0) {
        x = ( 0.5f + cameraCoordinateVector[0] / cameraCoordinateVector[3]) * width; 
        y = (0.5f -  cameraCoordinateVector[1] / cameraCoordinateVector[3]) * height; 
        pixelPoints.get(i).setName(points.get(i).getName());
        pixelPoints.get(i).setX(x);
        pixelPoints.get(i).setY(y);
        pixelPoints.get(i).setDist(distance);
        pixelPoints.get(i).setEle(points.get(i).getAlt());


      }
    }

    return new float[] { x, y };
  }

  // for storing the points in pixel coordinates
  public class Point {
    String name;
    double x;
    double y;
    double dist;
    int ele;

    public Point(String name, double x, double y, double dist, int ele) {
      this.name = name;
      this.x = x;
      this.y = y;
      this.dist = dist;
      this.ele = ele;
    }

    public String getName() {
      return name;
    }

    public double getX() {
      return x;
    }

    public double getY() {
      return y;
    }

    public double getDist() {
      return dist;
    }

    public int getEle() {
      return ele;
    }

    public void setName(String name) {
      this.name = name;
    }

    public void setX(double x) {
      this.x = x;
    }

    public void setY(double y) {
      this.y = y;
    }

    public void setDist(double dist) {
      this.dist = dist;
    }

    public void setEle(int ele) {
      this.ele = ele;
    }

  }

  // for storing the mountain peak dataset
  public class ARPoint {
    String name;
    double lat;
    double lon;
    int alt;

    public ARPoint(String name, double lat, double lon, int alt) {
      this.name = name;
      this.lat = lat;
      this.lon = lon;
      this.alt = alt;
    }

    public String getName() {
      return name;
    }

    public double getLat() {
      return lat;
    }

    public double getLon() {
      return lon;
    }

    public int getAlt() {
      return alt;
    }

  }

}