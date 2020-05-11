@JS()
library InteropGlobals;

import "dart:html" as HTML;
import "dart:js";
import "dart:math" as Math;
import "dart:typed_data";
import "dart:web_audio" as Audio;
import "dart:web_gl" as WebGL;

import "package:js/js.dart";

import "babylon.dart";
import "babylon_debug.dart";
import "interop_globals.dart";
import "promise.dart";

@JS()
abstract class EXT_disjoint_timer_query {
	
	external num get QUERY_COUNTER_BITS_EXT;
	external set QUERY_COUNTER_BITS_EXT(num value);
	
	external num get TIME_ELAPSED_EXT;
	external set TIME_ELAPSED_EXT(num value);
	
	external num get TIMESTAMP_EXT;
	external set TIMESTAMP_EXT(num value);
	
	external num get GPU_DISJOINT_EXT;
	external set GPU_DISJOINT_EXT(num value);
	
	external num get QUERY_RESULT_EXT;
	external set QUERY_RESULT_EXT(num value);
	
	external num get QUERY_RESULT_AVAILABLE_EXT;
	external set QUERY_RESULT_AVAILABLE_EXT(num value);
	
	external void queryCounterEXT(WebGL.Query query, num target);
	
	external WebGL.Query createQueryEXT();
	
	external void beginQueryEXT(num target, WebGL.Query query);
	
	external void endQueryEXT(num target);
	
	external dynamic getQueryObjectEXT(WebGL.Query query, num target);
	
	external void deleteQueryEXT(WebGL.Query query);
}

@JS()
abstract class VRDisplay {// extends HTML.EventTarget {
	external factory VRDisplay();
	
	/// Dictionary of capabilities describing the VRDisplay.
	external VRDisplayCapabilities get capabilities;
	
	/// z-depth defining the far plane of the eye view frustum
	/// enables mapping of values in the render target depth
	/// attachment to scene coordinates. Initially set to 10000.0.
	external num get depthFar;
	external set depthFar(num value);
	
	/// z-depth defining the near plane of the eye view frustum
	/// enables mapping of values in the render target depth
	/// attachment to scene coordinates. Initially set to 0.01.
	external num get depthNear;
	external set depthNear(num value);
	
	/// An identifier for this distinct VRDisplay. Used as an
	/// association point in the Gamepad API.
	external num get displayId;
	
	/// A display name, a user-readable name identifying it.
	external String get displayName;
	
	external bool get isConnected;
	
	external bool get isPresenting;
	
	/// If this VRDisplay supports room-scale experiences, the optional
	/// stage attribute contains details on the room-scale parameters.
	external VRStageParameters get stageParameters;
	
	/// Passing the value returned by `requestAnimationFrame` to
	/// `cancelAnimationFrame` will unregister the callback.
	/// @param handle Define the hanle of the request to cancel
	external void cancelAnimationFrame(num handle);
	
	/// Stops presenting to the VRDisplay.
	/// @returns a promise to know when it stopped
	external Promise<void> exitPresent();
	
	/// Return the current VREyeParameters for the given eye.
	/// @param whichEye Define the eye we want the parameter for
	/// @returns the eye parameters
	external VREyeParameters getEyeParameters(String whichEye);
	
	/// Populates the passed VRFrameData with the information required to render
	/// the current frame.
	/// @param frameData Define the data structure to populate
	/// @returns true if ok otherwise false
	external bool getFrameData(VRFrameData frameData);
	
	/// Get the layers currently being presented.
	/// @returns the list of VR layers
	external List<VRLayer> getLayers();
	
	/// Return a VRPose containing the future predicted pose of the VRDisplay
	/// when the current frame will be presented. The value returned will not
	/// change until JavaScript has returned control to the browser.
	/// 
	/// The VRPose will contain the position, orientation, velocity,
	/// and acceleration of each of these properties.
	/// @returns the pose object
	external VRPose getPose();
	
	/// Return the current instantaneous pose of the VRDisplay, with no
	/// prediction applied.
	/// @returns the current instantaneous pose
	external VRPose getImmediatePose();
	
	/// The callback passed to `requestAnimationFrame` will be called
	/// any time a new frame should be rendered. When the VRDisplay is
	/// presenting the callback will be called at the native refresh
	/// rate of the HMD. When not presenting this function acts
	/// identically to how window.requestAnimationFrame acts. Content should
	/// make no assumptions of frame rate or vsync behavior as the HMD runs
	/// asynchronously from other displays and at differing refresh rates.
	/// @param callback Define the eaction to run next frame
	/// @returns the request handle it
	external num requestAnimationFrame(dynamic /* unresolved: FrameRequestCallback */ callback);
	
	/// Begin presenting to the VRDisplay. Must be called in response to a user gesture.
	/// Repeat calls while already presenting will update the VRLayers being displayed.
	/// @param layers Define the list of layer to present
	/// @returns a promise to know when the request has been fulfilled
	external Promise<void> requestPresent(List<VRLayer> layers);
	
	/// Reset the pose for this display, treating its current position and
	/// orientation as the "origin/zero" values. VRPose.position,
	/// VRPose.orientation, and VRStageParameters.sittingToStandingTransform may be
	/// updated when calling resetPose(). This should be called in only
	/// sitting-space experiences.
	external void resetPose();
	
	/// The VRLayer provided to the VRDisplay will be captured and presented
	/// in the HMD. Calling this function has the same effect on the source
	/// canvas as any other operation that uses its source image, and canvases
	/// created without preserveDrawingBuffer set to true will be cleared.
	/// @param pose Define the pose to submit
	external void submitFrame([VRPose pose]);
}

/* var */
@JS("VRDisplay")
external dynamic get VRDisplay_js;

@JS()
abstract class VRLayer {
	
	external dynamic get leftBounds;
	external set leftBounds(dynamic value);
	
	external dynamic get rightBounds;
	external set rightBounds(dynamic value);
	
	external HTML.CanvasElement get source;
	external set source(HTML.CanvasElement value);
}

@JS()
abstract class VRDisplayCapabilities {
	
	external bool get canPresent;
	
	external bool get hasExternalDisplay;
	
	external bool get hasOrientation;
	
	external bool get hasPosition;
	
	external num get maxLayers;
}

@JS()
abstract class VREyeParameters {
	
	/// @deprecated
	external VRFieldOfView get fieldOfView;
	
	external Float32List get offset;
	
	external num get renderHeight;
	
	external num get renderWidth;
}

@JS()
abstract class VRFieldOfView {
	
	external num get downDegrees;
	
	external num get leftDegrees;
	
	external num get rightDegrees;
	
	external num get upDegrees;
}

@JS()
abstract class VRFrameData {
	
	external Float32List get leftProjectionMatrix;
	
	external Float32List get leftViewMatrix;
	
	external VRPose get pose;
	
	external Float32List get rightProjectionMatrix;
	
	external Float32List get rightViewMatrix;
	
	external num get timestamp;
}

@JS()
abstract class VRPose {
	
	external Float32List get angularAcceleration;
	
	external Float32List get angularVelocity;
	
	external Float32List get linearAcceleration;
	
	external Float32List get linearVelocity;
	
	external Float32List get orientation;
	
	external Float32List get position;
	
	external num get timestamp;
}

@JS()
abstract class VRStageParameters {
	
	external Float32List get sittingToStandingTransform;
	external set sittingToStandingTransform(Float32List value);
	
	external num get sizeX;
	external set sizeX(num value);
	
	external num get sizeY;
	external set sizeY(num value);
}

@JS()
abstract class XRSessionInit {
	
	external List<dynamic> get optionalFeatures;
	external set optionalFeatures(List<dynamic> value);
	
	external List<dynamic> get requiredFeatures;
	external set requiredFeatures(List<dynamic> value);
}

@JS()
abstract class XRWebGLLayerOptions {
	
	external bool get antialias;
	external set antialias(bool value);
	
	external bool get depth;
	external set depth(bool value);
	
	external bool get stencil;
	external set stencil(bool value);
	
	external bool get alpha;
	external set alpha(bool value);
	
	external bool get multiview;
	external set multiview(bool value);
	
	external num get framebufferScaleFactor;
	external set framebufferScaleFactor(num value);
}

@JS()
abstract class XRInputSourceChangeEvent {
	
	external dynamic get session;
	external set session(dynamic value);
	
	external List<dynamic> get removed;
	external set removed(List<dynamic> value);
	
	external List<dynamic> get added;
	external set added(List<dynamic> value);
}

@JS()
class XRRay {
	
	external factory XRRay(dynamic transformOrOrigin, [dynamic /* unresolved: DOMPointInit */ direction]);
	
	external HTML.DomPointReadOnly get origin;
	external set origin(HTML.DomPointReadOnly value);
	
	external HTML.DomPointReadOnly get direction;
	external set direction(HTML.DomPointReadOnly value);
	
	external Float32List get matrix;
	external set matrix(Float32List value);
}

@JS()
abstract class XRHitResult {
	
	external Float32List get hitMatrix;
	external set hitMatrix(Float32List value);
}

@JS()
abstract class XRAnchor {
	
	external String get id;
	external set id(String value);
	
	external dynamic get anchorSpace;
	external set anchorSpace(dynamic value);
	
	external num get lastChangedTime;
	external set lastChangedTime(num value);
	
	external void detach();
}

@JS()
abstract class XRPlane implements XRAnchorCreator {
	
	external String get orientation;
	external set orientation(String value);
	
	external dynamic get planeSpace;
	external set planeSpace(dynamic value);
	
	external List<HTML.DomPointReadOnly> get polygon;
	external set polygon(List<HTML.DomPointReadOnly> value);
	
	external num get lastChangedTime;
	external set lastChangedTime(num value);
}

@JS()
abstract class XRAnchorCreator {
	
	external Promise<XRAnchor> createAnchor(dynamic pose, dynamic referenceSpace);
}

@JS()
@anonymous
class FileToolsSetCorsBehaviorElement {
	
	external factory FileToolsSetCorsBehaviorElement({String crossOrigin});
	
	external String get crossOrigin;
	external set crossOrigin( String value );
}

@JS()
@anonymous
class MatrixPerspectiveFovWebVRToRefFov {
	
	external factory MatrixPerspectiveFovWebVRToRefFov({num upDegrees, num downDegrees, num leftDegrees, num rightDegrees});
	
	external num get upDegrees;
	external set upDegrees( num value );
	
	external num get downDegrees;
	external set downDegrees( num value );
	
	external num get leftDegrees;
	external set leftDegrees( num value );
	
	external num get rightDegrees;
	external set rightDegrees( num value );
}

@JS()
@anonymous
class ExtractMinAndMaxIndexed {
	
	external factory ExtractMinAndMaxIndexed({Vector3 minimum, Vector3 maximum});
	
	external Vector3 get minimum;
	external set minimum( Vector3 value );
	
	external Vector3 get maximum;
	external set maximum( Vector3 value );
}

@JS()
@anonymous
class ExtractMinAndMax {
	
	external factory ExtractMinAndMax({Vector3 minimum, Vector3 maximum});
	
	external Vector3 get minimum;
	external set minimum( Vector3 value );
	
	external Vector3 get maximum;
	external set maximum( Vector3 value );
}

@JS()
@anonymous
class ThinEngineExceptionList {
	
	external factory ThinEngineExceptionList({String key, String capture, num captureConstraint, List<String> targets});
	
	external String get key;
	external set key( String value );
	
	external String get capture;
	external set capture( String value );
	
	external num get captureConstraint;
	external set captureConstraint( num value );
	
	external List<String> get targets;
	external set targets( List<String> value );
}

@JS()
@anonymous
class ThinEngineFramebufferDimensionsObjectDimensions {
	
	external factory ThinEngineFramebufferDimensionsObjectDimensions({num framebufferWidth, num framebufferHeight});
	
	external num get framebufferWidth;
	external set framebufferWidth( num value );
	
	external num get framebufferHeight;
	external set framebufferHeight( num value );
}

@JS()
@anonymous
class ThinEngineGetGlInfo {
	
	external factory ThinEngineGetGlInfo({String vendor, String renderer, String version});
	
	external String get vendor;
	external set vendor( String value );
	
	external String get renderer;
	external set renderer( String value );
	
	external String get version;
	external set version( String value );
}

@JS()
@anonymous
class MaterialHelperPrepareDefinesForLightState {
	
	external factory MaterialHelperPrepareDefinesForLightState({bool needNormals, bool needRebuild, bool shadowEnabled, bool specularEnabled, bool lightmapMode});
	
	external bool get needNormals;
	external set needNormals( bool value );
	
	external bool get needRebuild;
	external set needRebuild( bool value );
	
	external bool get shadowEnabled;
	external set shadowEnabled( bool value );
	
	external bool get specularEnabled;
	external set specularEnabled( bool value );
	
	external bool get lightmapMode;
	external set lightmapMode( bool value );
}

@JS()
@anonymous
class SceneGetWorldExtends {
	
	external factory SceneGetWorldExtends({Vector3 min, Vector3 max});
	
	external Vector3 get min;
	external set min( Vector3 value );
	
	external Vector3 get max;
	external set max( Vector3 value );
}

@JS()
@anonymous
class StageObject<T> {
	
	external factory StageObject({num index, ISceneComponent component, T action});
	
	external num get index;
	external set index( num value );
	
	external ISceneComponent get component;
	external set component( ISceneComponent value );
	
	external T get action;
	external set action( T value );
}

@JS()
@anonymous
class TransformNodeInstantiateHierarchyOptions {
	
	external factory TransformNodeInstantiateHierarchyOptions({bool doNotInstantiate});
	
	external bool get doNotInstantiate;
	external set doNotInstantiate( bool value );
}

@JS()
@anonymous
class MeshInstantiateHierarchyOptions {
	
	external factory MeshInstantiateHierarchyOptions({bool doNotInstantiate});
	
	external bool get doNotInstantiate;
	external set doNotInstantiate( bool value );
}

@JS()
@anonymous
class MeshValidateSkinning {
	
	external factory MeshValidateSkinning({bool skinned, bool valid, String report});
	
	external bool get skinned;
	external set skinned( bool value );
	
	external bool get valid;
	external set valid( bool value );
	
	external String get report;
	external set report( String value );
}

@JS()
@anonymous
class MeshCreateTiledGroundSubdivisions {
	
	external factory MeshCreateTiledGroundSubdivisions({num w, num h});
	
	external num get w;
	external set w( num value );
	
	external num get h;
	external set h( num value );
}

@JS()
@anonymous
class MeshCreateTiledGroundPrecision {
	
	external factory MeshCreateTiledGroundPrecision({num w, num h});
	
	external num get w;
	external set w( num value );
	
	external num get h;
	external set h( num value );
}

@JS()
@anonymous
class MeshCreatePolyhedronOptions {
	
	external factory MeshCreatePolyhedronOptions({num type, num size, num sizeX, num sizeY, num sizeZ, dynamic custom, List<Vector4> faceUV, List<Color4> faceColors, bool updatable, num sideOrientation});
	
	external num get type;
	external set type( num value );
	
	external num get size;
	external set size( num value );
	
	external num get sizeX;
	external set sizeX( num value );
	
	external num get sizeY;
	external set sizeY( num value );
	
	external num get sizeZ;
	external set sizeZ( num value );
	
	external dynamic get custom;
	external set custom( dynamic value );
	
	external List<Vector4> get faceUV;
	external set faceUV( List<Vector4> value );
	
	external List<Color4> get faceColors;
	external set faceColors( List<Color4> value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
}

@JS()
@anonymous
class MeshCreateIcoSphereOptions {
	
	external factory MeshCreateIcoSphereOptions({num radius, bool flat, num subdivisions, num sideOrientation, bool updatable});
	
	external num get radius;
	external set radius( num value );
	
	external bool get flat;
	external set flat( bool value );
	
	external num get subdivisions;
	external set subdivisions( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external bool get updatable;
	external set updatable( bool value );
}

@JS()
@anonymous
class MeshMinMax {
	
	external factory MeshMinMax({Vector3 min, Vector3 max});
	
	external Vector3 get min;
	external set min( Vector3 value );
	
	external Vector3 get max;
	external set max( Vector3 value );
}

@JS()
@anonymous
class MeshCenterMeshesOrMinMaxVector {
	
	external factory MeshCenterMeshesOrMinMaxVector({Vector3 min, Vector3 max});
	
	external Vector3 get min;
	external set min( Vector3 value );
	
	external Vector3 get max;
	external set max( Vector3 value );
}

@JS()
@anonymous
class IShadowGeneratorForceCompilationOptions {
	
	external factory IShadowGeneratorForceCompilationOptions({bool useInstances});
	
	external bool get useInstances;
	external set useInstances( bool value );
}

@JS()
@anonymous
class IShadowGeneratorForceCompilationAsyncOptions {
	
	external factory IShadowGeneratorForceCompilationAsyncOptions({bool useInstances});
	
	external bool get useInstances;
	external set useInstances( bool value );
}

@JS()
@anonymous
class ShadowGeneratorForceCompilationOptions {
	
	external factory ShadowGeneratorForceCompilationOptions({bool useInstances});
	
	external bool get useInstances;
	external set useInstances( bool value );
}

@JS()
@anonymous
class ShadowGeneratorForceCompilationAsyncOptions {
	
	external factory ShadowGeneratorForceCompilationAsyncOptions({bool useInstances});
	
	external bool get useInstances;
	external set useInstances( bool value );
}

@JS()
@anonymous
class FreeCameraMouseInputOnPointerMovedObservable {
	
	external factory FreeCameraMouseInputOnPointerMovedObservable({num offsetX, num offsetY});
	
	external num get offsetX;
	external set offsetX( num value );
	
	external num get offsetY;
	external set offsetY( num value );
}

@JS()
@anonymous
class MultiviewRenderTargetConstructorSize {
	
	external factory MultiviewRenderTargetConstructorSize({num width, num height, num ratio});
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get ratio;
	external set ratio( num value );
}

@JS()
@anonymous
class PostProcessOptionsObject {
	
	external factory PostProcessOptionsObject({num width, num height});
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
}

@JS()
@anonymous
class MirrorTextureConstructorSize {
	
	external factory MirrorTextureConstructorSize({num width, num height, num ratio});
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get ratio;
	external set ratio( num value );
}

@JS()
@anonymous
class RenderTargetTextureResizeSize {
	
	external factory RenderTargetTextureResizeSize({num width, num height, num ratio});
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get ratio;
	external set ratio( num value );
}

@JS()
@anonymous
class RenderTargetTextureConstructorSize {
	
	external factory RenderTargetTextureConstructorSize({num width, num height, num layers, num ratio});
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get layers;
	external set layers( num value );
	
	external num get ratio;
	external set ratio( num value );
}

@JS()
@anonymous
class GeometryExtend {
	
	external factory GeometryExtend({Vector3 minimum, Vector3 maximum});
	
	external Vector3 get minimum;
	external set minimum( Vector3 value );
	
	external Vector3 get maximum;
	external set maximum( Vector3 value );
}

@JS()
@anonymous
class VertexDataCreateRibbonOptions {
	
	external factory VertexDataCreateRibbonOptions({List<List<Vector3>> pathArray, bool closeArray, bool closePath, num offset, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, bool invertUV, List<Vector2> uvs, List<Color4> colors});
	
	external List<List<Vector3>> get pathArray;
	external set pathArray( List<List<Vector3>> value );
	
	external bool get closeArray;
	external set closeArray( bool value );
	
	external bool get closePath;
	external set closePath( bool value );
	
	external num get offset;
	external set offset( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external bool get invertUV;
	external set invertUV( bool value );
	
	external List<Vector2> get uvs;
	external set uvs( List<Vector2> value );
	
	external List<Color4> get colors;
	external set colors( List<Color4> value );
}

@JS()
@anonymous
class VertexDataCreateBoxOptions {
	
	external factory VertexDataCreateBoxOptions({num size, num width, num height, num depth, List<Vector4> faceUV, List<Color4> faceColors, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get size;
	external set size( num value );
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get depth;
	external set depth( num value );
	
	external List<Vector4> get faceUV;
	external set faceUV( List<Vector4> value );
	
	external List<Color4> get faceColors;
	external set faceColors( List<Color4> value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class VertexDataCreateTiledBoxOptions {
	
	external factory VertexDataCreateTiledBoxOptions({num pattern, num width, num height, num depth, num tileSize, num tileWidth, num tileHeight, num alignHorizontal, num alignVertical, List<Vector4> faceUV, List<Color4> faceColors, num sideOrientation});
	
	external num get pattern;
	external set pattern( num value );
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get depth;
	external set depth( num value );
	
	external num get tileSize;
	external set tileSize( num value );
	
	external num get tileWidth;
	external set tileWidth( num value );
	
	external num get tileHeight;
	external set tileHeight( num value );
	
	external num get alignHorizontal;
	external set alignHorizontal( num value );
	
	external num get alignVertical;
	external set alignVertical( num value );
	
	external List<Vector4> get faceUV;
	external set faceUV( List<Vector4> value );
	
	external List<Color4> get faceColors;
	external set faceColors( List<Color4> value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
}

@JS()
@anonymous
class VertexDataCreateTiledPlaneOptions {
	
	external factory VertexDataCreateTiledPlaneOptions({num pattern, num tileSize, num tileWidth, num tileHeight, num size, num width, num height, num alignHorizontal, num alignVertical, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get pattern;
	external set pattern( num value );
	
	external num get tileSize;
	external set tileSize( num value );
	
	external num get tileWidth;
	external set tileWidth( num value );
	
	external num get tileHeight;
	external set tileHeight( num value );
	
	external num get size;
	external set size( num value );
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get alignHorizontal;
	external set alignHorizontal( num value );
	
	external num get alignVertical;
	external set alignVertical( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class VertexDataCreateSphereOptions {
	
	external factory VertexDataCreateSphereOptions({num segments, num diameter, num diameterX, num diameterY, num diameterZ, num arc, num slice, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get segments;
	external set segments( num value );
	
	external num get diameter;
	external set diameter( num value );
	
	external num get diameterX;
	external set diameterX( num value );
	
	external num get diameterY;
	external set diameterY( num value );
	
	external num get diameterZ;
	external set diameterZ( num value );
	
	external num get arc;
	external set arc( num value );
	
	external num get slice;
	external set slice( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class VertexDataCreateCylinderOptions {
	
	external factory VertexDataCreateCylinderOptions({num height, num diameterTop, num diameterBottom, num diameter, num tessellation, num subdivisions, num arc, List<Color4> faceColors, List<Vector4> faceUV, bool hasRings, bool enclose, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get height;
	external set height( num value );
	
	external num get diameterTop;
	external set diameterTop( num value );
	
	external num get diameterBottom;
	external set diameterBottom( num value );
	
	external num get diameter;
	external set diameter( num value );
	
	external num get tessellation;
	external set tessellation( num value );
	
	external num get subdivisions;
	external set subdivisions( num value );
	
	external num get arc;
	external set arc( num value );
	
	external List<Color4> get faceColors;
	external set faceColors( List<Color4> value );
	
	external List<Vector4> get faceUV;
	external set faceUV( List<Vector4> value );
	
	external bool get hasRings;
	external set hasRings( bool value );
	
	external bool get enclose;
	external set enclose( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class VertexDataCreateTorusOptions {
	
	external factory VertexDataCreateTorusOptions({num diameter, num thickness, num tessellation, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get diameter;
	external set diameter( num value );
	
	external num get thickness;
	external set thickness( num value );
	
	external num get tessellation;
	external set tessellation( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class VertexDataCreateLineSystemOptions {
	
	external factory VertexDataCreateLineSystemOptions({List<List<Vector3>> lines, List<List<Color4>> colors});
	
	external List<List<Vector3>> get lines;
	external set lines( List<List<Vector3>> value );
	
	external List<List<Color4>> get colors;
	external set colors( List<List<Color4>> value );
}

@JS()
@anonymous
class VertexDataCreateDashedLinesOptions {
	
	external factory VertexDataCreateDashedLinesOptions({List<Vector3> points, num dashSize, num gapSize, num dashNb});
	
	external List<Vector3> get points;
	external set points( List<Vector3> value );
	
	external num get dashSize;
	external set dashSize( num value );
	
	external num get gapSize;
	external set gapSize( num value );
	
	external num get dashNb;
	external set dashNb( num value );
}

@JS()
@anonymous
class VertexDataCreateGroundOptions {
	
	external factory VertexDataCreateGroundOptions({num width, num height, num subdivisions, num subdivisionsX, num subdivisionsY});
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get subdivisions;
	external set subdivisions( num value );
	
	external num get subdivisionsX;
	external set subdivisionsX( num value );
	
	external num get subdivisionsY;
	external set subdivisionsY( num value );
}

@JS()
@anonymous
class VertexDataCreateTiledGroundOptions {
	
	external factory VertexDataCreateTiledGroundOptions({num xmin, num zmin, num xmax, num zmax, VertexDataCreateTiledGroundOptionsSubdivisions subdivisions, VertexDataCreateTiledGroundOptionsPrecision precision});
	
	external num get xmin;
	external set xmin( num value );
	
	external num get zmin;
	external set zmin( num value );
	
	external num get xmax;
	external set xmax( num value );
	
	external num get zmax;
	external set zmax( num value );
	
	external VertexDataCreateTiledGroundOptionsSubdivisions get subdivisions;
	external set subdivisions( VertexDataCreateTiledGroundOptionsSubdivisions value );
	
	external VertexDataCreateTiledGroundOptionsPrecision get precision;
	external set precision( VertexDataCreateTiledGroundOptionsPrecision value );
}

@JS()
@anonymous
class VertexDataCreateTiledGroundOptionsSubdivisions {
	
	external factory VertexDataCreateTiledGroundOptionsSubdivisions({num w, num h});
	
	external num get w;
	external set w( num value );
	
	external num get h;
	external set h( num value );
}

@JS()
@anonymous
class VertexDataCreateTiledGroundOptionsPrecision {
	
	external factory VertexDataCreateTiledGroundOptionsPrecision({num w, num h});
	
	external num get w;
	external set w( num value );
	
	external num get h;
	external set h( num value );
}

@JS()
@anonymous
class VertexDataCreateGroundFromHeightMapOptions {
	
	external factory VertexDataCreateGroundFromHeightMapOptions({num width, num height, num subdivisions, num minHeight, num maxHeight, Color3 colorFilter, Uint8List buffer, num bufferWidth, num bufferHeight, num alphaFilter});
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get subdivisions;
	external set subdivisions( num value );
	
	external num get minHeight;
	external set minHeight( num value );
	
	external num get maxHeight;
	external set maxHeight( num value );
	
	external Color3 get colorFilter;
	external set colorFilter( Color3 value );
	
	external Uint8List get buffer;
	external set buffer( Uint8List value );
	
	external num get bufferWidth;
	external set bufferWidth( num value );
	
	external num get bufferHeight;
	external set bufferHeight( num value );
	
	external num get alphaFilter;
	external set alphaFilter( num value );
}

@JS()
@anonymous
class VertexDataCreatePlaneOptions {
	
	external factory VertexDataCreatePlaneOptions({num size, num width, num height, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get size;
	external set size( num value );
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class VertexDataCreateDiscOptions {
	
	external factory VertexDataCreateDiscOptions({num radius, num tessellation, num arc, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get radius;
	external set radius( num value );
	
	external num get tessellation;
	external set tessellation( num value );
	
	external num get arc;
	external set arc( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class VertexDataCreateIcoSphereOptions {
	
	external factory VertexDataCreateIcoSphereOptions({num radius, num radiusX, num radiusY, num radiusZ, bool flat, num subdivisions, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get radius;
	external set radius( num value );
	
	external num get radiusX;
	external set radiusX( num value );
	
	external num get radiusY;
	external set radiusY( num value );
	
	external num get radiusZ;
	external set radiusZ( num value );
	
	external bool get flat;
	external set flat( bool value );
	
	external num get subdivisions;
	external set subdivisions( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class VertexDataCreatePolyhedronOptions {
	
	external factory VertexDataCreatePolyhedronOptions({num type, num size, num sizeX, num sizeY, num sizeZ, dynamic custom, List<Vector4> faceUV, List<Color4> faceColors, bool flat, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get type;
	external set type( num value );
	
	external num get size;
	external set size( num value );
	
	external num get sizeX;
	external set sizeX( num value );
	
	external num get sizeY;
	external set sizeY( num value );
	
	external num get sizeZ;
	external set sizeZ( num value );
	
	external dynamic get custom;
	external set custom( dynamic value );
	
	external List<Vector4> get faceUV;
	external set faceUV( List<Vector4> value );
	
	external List<Color4> get faceColors;
	external set faceColors( List<Color4> value );
	
	external bool get flat;
	external set flat( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class VertexDataCreateTorusKnotOptions {
	
	external factory VertexDataCreateTorusKnotOptions({num radius, num tube, num radialSegments, num tubularSegments, num p, num q, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get radius;
	external set radius( num value );
	
	external num get tube;
	external set tube( num value );
	
	external num get radialSegments;
	external set radialSegments( num value );
	
	external num get tubularSegments;
	external set tubularSegments( num value );
	
	external num get p;
	external set p( num value );
	
	external num get q;
	external set q( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class VertexDataComputeNormalsOptions {
	
	external factory VertexDataComputeNormalsOptions({dynamic facetNormals, dynamic facetPositions, dynamic facetPartitioning, num ratio, dynamic bInfo, Vector3 bbSize, dynamic subDiv, bool useRightHandedSystem, bool depthSort, Vector3 distanceTo, dynamic depthSortedFacets});
	
	external dynamic get facetNormals;
	external set facetNormals( dynamic value );
	
	external dynamic get facetPositions;
	external set facetPositions( dynamic value );
	
	external dynamic get facetPartitioning;
	external set facetPartitioning( dynamic value );
	
	external num get ratio;
	external set ratio( num value );
	
	external dynamic get bInfo;
	external set bInfo( dynamic value );
	
	external Vector3 get bbSize;
	external set bbSize( Vector3 value );
	
	external dynamic get subDiv;
	external set subDiv( dynamic value );
	
	external bool get useRightHandedSystem;
	external set useRightHandedSystem( bool value );
	
	external bool get depthSort;
	external set depthSort( bool value );
	
	external Vector3 get distanceTo;
	external set distanceTo( Vector3 value );
	
	external dynamic get depthSortedFacets;
	external set depthSortedFacets( dynamic value );
}

@JS()
@anonymous
class PhysicsImpostorOnCollideE {
	
	external factory PhysicsImpostorOnCollideE({dynamic body});
	
	external dynamic get body;
	external set body( dynamic value );
}

@JS()
@anonymous
class DiscBuilderCreateDiscOptions {
	
	external factory DiscBuilderCreateDiscOptions({num radius, num tessellation, num arc, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get radius;
	external set radius( num value );
	
	external num get tessellation;
	external set tessellation( num value );
	
	external num get arc;
	external set arc( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class SolidParticleSystemPickedParticles {
	
	external factory SolidParticleSystemPickedParticles({num idx, num faceId});
	
	external num get idx;
	external set idx( num value );
	
	external num get faceId;
	external set faceId( num value );
}

@JS()
@anonymous
class SolidParticleSystemDigestOptions {
	
	external factory SolidParticleSystemDigestOptions({num facetNb, num number, num delta, List<dynamic> storage});
	
	external num get facetNb;
	external set facetNb( num value );
	
	external num get number;
	external set number( num value );
	
	external num get delta;
	external set delta( num value );
	
	external List<dynamic> get storage;
	external set storage( List<dynamic> value );
}

@JS()
@anonymous
class SolidParticleSystemAddShapeOptions {
	
	external factory SolidParticleSystemAddShapeOptions({dynamic positionFunction, dynamic vertexFunction, List<dynamic> storage});
	
	external dynamic get positionFunction;
	external set positionFunction( dynamic value );
	
	external dynamic get vertexFunction;
	external set vertexFunction( dynamic value );
	
	external List<dynamic> get storage;
	external set storage( List<dynamic> value );
}

@JS()
@anonymous
class SolidParticleSystemConstructorOptions {
	
	external factory SolidParticleSystemConstructorOptions({bool updatable, bool isPickable, bool enableDepthSort, bool particleIntersection, bool boundingSphereOnly, num bSphereRadiusFactor, bool expandable, bool useModelMaterial, bool enableMultiMaterial});
	
	external bool get updatable;
	external set updatable( bool value );
	
	external bool get isPickable;
	external set isPickable( bool value );
	
	external bool get enableDepthSort;
	external set enableDepthSort( bool value );
	
	external bool get particleIntersection;
	external set particleIntersection( bool value );
	
	external bool get boundingSphereOnly;
	external set boundingSphereOnly( bool value );
	
	external num get bSphereRadiusFactor;
	external set bSphereRadiusFactor( num value );
	
	external bool get expandable;
	external set expandable( bool value );
	
	external bool get useModelMaterial;
	external set useModelMaterial( bool value );
	
	external bool get enableMultiMaterial;
	external set enableMultiMaterial( bool value );
}

@JS()
@anonymous
class NodeGetHierarchyBoundingVectors {
	
	external factory NodeGetHierarchyBoundingVectors({Vector3 min, Vector3 max});
	
	external Vector3 get min;
	external set min( Vector3 value );
	
	external Vector3 get max;
	external set max( Vector3 value );
}

@JS()
@anonymous
class EngineCapabilitiesParallelShaderCompile {
	
	external factory EngineCapabilitiesParallelShaderCompile({num COMPLETION_STATUS_KHR});
	
	external num get COMPLETION_STATUS_KHR;
	external set COMPLETION_STATUS_KHR( num value );
}

@JS()
@anonymous
class VideoTextureCreateFromWebCamAsyncConstraints {
	
	external factory VideoTextureCreateFromWebCamAsyncConstraints({num minWidth, num maxWidth, num minHeight, num maxHeight, String deviceId});
	
	external num get minWidth;
	external set minWidth( num value );
	
	external num get maxWidth;
	external set maxWidth( num value );
	
	external num get minHeight;
	external set minHeight( num value );
	
	external num get maxHeight;
	external set maxHeight( num value );
	
	external String get deviceId;
	external set deviceId( String value );
}

@JS()
@anonymous
class VideoTextureCreateFromWebCamConstraints {
	
	external factory VideoTextureCreateFromWebCamConstraints({num minWidth, num maxWidth, num minHeight, num maxHeight, String deviceId});
	
	external num get minWidth;
	external set minWidth( num value );
	
	external num get maxWidth;
	external set maxWidth( num value );
	
	external num get minHeight;
	external set minHeight( num value );
	
	external num get maxHeight;
	external set maxHeight( num value );
	
	external String get deviceId;
	external set deviceId( String value );
}

@JS()
@anonymous
class AnalyserDEBUGCANVASPOS {
	
	external factory AnalyserDEBUGCANVASPOS({num x, num y});
	
	external num get x;
	external set x( num value );
	
	external num get y;
	external set y( num value );
}

@JS()
@anonymous
class AnalyserDEBUGCANVASSIZE {
	
	external factory AnalyserDEBUGCANVASSIZE({num width, num height});
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
}

@JS()
@anonymous
class ToolsSetCorsBehaviorElement {
	
	external factory ToolsSetCorsBehaviorElement({String crossOrigin});
	
	external String get crossOrigin;
	external set crossOrigin( String value );
}

@JS()
@anonymous
class ToolsRegisterTopRootEventsEvents {
	
	external factory ToolsRegisterTopRootEventsEvents({String name, dynamic Function(HTML.FocusEvent e) handler});
	
	external String get name;
	external set name( String value );
	
	external dynamic Function(HTML.FocusEvent e) get handler;
	external set handler( dynamic Function(HTML.FocusEvent e) value );
}

@JS()
@anonymous
class ToolsUnregisterTopRootEventsEvents {
	
	external factory ToolsUnregisterTopRootEventsEvents({String name, dynamic Function(HTML.FocusEvent e) handler});
	
	external String get name;
	external set name( String value );
	
	external dynamic Function(HTML.FocusEvent e) get handler;
	external set handler( dynamic Function(HTML.FocusEvent e) value );
}

@JS()
@anonymous
class ArcRotateCameraFocusOnMeshesOrMinMaxVectorAndDistance {
	
	external factory ArcRotateCameraFocusOnMeshesOrMinMaxVectorAndDistance({Vector3 min, Vector3 max, num distance});
	
	external Vector3 get min;
	external set min( Vector3 value );
	
	external Vector3 get max;
	external set max( Vector3 value );
	
	external num get distance;
	external set distance( num value );
}

@JS()
@anonymous
class PlaneBuilderCreatePlaneOptions {
	
	external factory PlaneBuilderCreatePlaneOptions({num size, num width, num height, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, bool updatable, Plane sourcePlane});
	
	external num get size;
	external set size( num value );
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external Plane get sourcePlane;
	external set sourcePlane( Plane value );
}

@JS()
@anonymous
class PointerDragBehaviorOnDragObservable {
	
	external factory PointerDragBehaviorOnDragObservable({Vector3 delta, Vector3 dragPlanePoint, Vector3 dragPlaneNormal, num dragDistance, num pointerId});
	
	external Vector3 get delta;
	external set delta( Vector3 value );
	
	external Vector3 get dragPlanePoint;
	external set dragPlanePoint( Vector3 value );
	
	external Vector3 get dragPlaneNormal;
	external set dragPlaneNormal( Vector3 value );
	
	external num get dragDistance;
	external set dragDistance( num value );
	
	external num get pointerId;
	external set pointerId( num value );
}

@JS()
@anonymous
class PointerDragBehaviorOnDragStartObservable {
	
	external factory PointerDragBehaviorOnDragStartObservable({Vector3 dragPlanePoint, num pointerId});
	
	external Vector3 get dragPlanePoint;
	external set dragPlanePoint( Vector3 value );
	
	external num get pointerId;
	external set pointerId( num value );
}

@JS()
@anonymous
class PointerDragBehaviorOnDragEndObservable {
	
	external factory PointerDragBehaviorOnDragEndObservable({Vector3 dragPlanePoint, num pointerId});
	
	external Vector3 get dragPlanePoint;
	external set dragPlanePoint( Vector3 value );
	
	external num get pointerId;
	external set pointerId( num value );
}

@JS()
@anonymous
class PointerDragBehaviorOptions {
	
	external factory PointerDragBehaviorOptions({Vector3 dragAxis, Vector3 dragPlaneNormal});
	
	external Vector3 get dragAxis;
	external set dragAxis( Vector3 value );
	
	external Vector3 get dragPlaneNormal;
	external set dragPlaneNormal( Vector3 value );
}

@JS()
@anonymous
class PointerDragBehaviorOptionsOptions {
	
	external factory PointerDragBehaviorOptionsOptions({Vector3 dragAxis, Vector3 dragPlaneNormal});
	
	external Vector3 get dragAxis;
	external set dragAxis( Vector3 value );
	
	external Vector3 get dragPlaneNormal;
	external set dragPlaneNormal( Vector3 value );
}

@JS()
@anonymous
class PointerDragBehaviorConstructorOptions {
	
	external factory PointerDragBehaviorConstructorOptions({Vector3 dragAxis, Vector3 dragPlaneNormal});
	
	external Vector3 get dragAxis;
	external set dragAxis( Vector3 value );
	
	external Vector3 get dragPlaneNormal;
	external set dragPlaneNormal( Vector3 value );
}

@JS()
@anonymous
class BoneIKControllerConstructorOptions {
	
	external factory BoneIKControllerConstructorOptions({AbstractMesh targetMesh, AbstractMesh poleTargetMesh, Bone poleTargetBone, Vector3 poleTargetLocalOffset, num poleAngle, Vector3 bendAxis, num maxAngle, num slerpAmount});
	
	external AbstractMesh get targetMesh;
	external set targetMesh( AbstractMesh value );
	
	external AbstractMesh get poleTargetMesh;
	external set poleTargetMesh( AbstractMesh value );
	
	external Bone get poleTargetBone;
	external set poleTargetBone( Bone value );
	
	external Vector3 get poleTargetLocalOffset;
	external set poleTargetLocalOffset( Vector3 value );
	
	external num get poleAngle;
	external set poleAngle( num value );
	
	external Vector3 get bendAxis;
	external set bendAxis( Vector3 value );
	
	external num get maxAngle;
	external set maxAngle( num value );
	
	external num get slerpAmount;
	external set slerpAmount( num value );
}

@JS()
@anonymous
class BoneLookControllerConstructorOptions {
	
	external factory BoneLookControllerConstructorOptions({num maxYaw, num minYaw, num maxPitch, num minPitch, num slerpAmount, Vector3 upAxis, int upAxisSpace, Vector3 yawAxis, Vector3 pitchAxis, num adjustYaw, num adjustPitch, num adjustRoll});
	
	external num get maxYaw;
	external set maxYaw( num value );
	
	external num get minYaw;
	external set minYaw( num value );
	
	external num get maxPitch;
	external set maxPitch( num value );
	
	external num get minPitch;
	external set minPitch( num value );
	
	external num get slerpAmount;
	external set slerpAmount( num value );
	
	external Vector3 get upAxis;
	external set upAxis( Vector3 value );
	
	external int get upAxisSpace;
	external set upAxisSpace( int value );
	
	external Vector3 get yawAxis;
	external set yawAxis( Vector3 value );
	
	external Vector3 get pitchAxis;
	external set pitchAxis( Vector3 value );
	
	external num get adjustYaw;
	external set adjustYaw( num value );
	
	external num get adjustPitch;
	external set adjustPitch( num value );
	
	external num get adjustRoll;
	external set adjustRoll( num value );
}

@JS()
@anonymous
class GroundBuilderCreateGroundOptions {
	
	external factory GroundBuilderCreateGroundOptions({num width, num height, num subdivisions, num subdivisionsX, num subdivisionsY, bool updatable});
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get subdivisions;
	external set subdivisions( num value );
	
	external num get subdivisionsX;
	external set subdivisionsX( num value );
	
	external num get subdivisionsY;
	external set subdivisionsY( num value );
	
	external bool get updatable;
	external set updatable( bool value );
}

@JS()
@anonymous
class GroundBuilderCreateTiledGroundOptions {
	
	external factory GroundBuilderCreateTiledGroundOptions({num xmin, num zmin, num xmax, num zmax, GroundBuilderCreateTiledGroundOptionsSubdivisions subdivisions, GroundBuilderCreateTiledGroundOptionsPrecision precision, bool updatable});
	
	external num get xmin;
	external set xmin( num value );
	
	external num get zmin;
	external set zmin( num value );
	
	external num get xmax;
	external set xmax( num value );
	
	external num get zmax;
	external set zmax( num value );
	
	external GroundBuilderCreateTiledGroundOptionsSubdivisions get subdivisions;
	external set subdivisions( GroundBuilderCreateTiledGroundOptionsSubdivisions value );
	
	external GroundBuilderCreateTiledGroundOptionsPrecision get precision;
	external set precision( GroundBuilderCreateTiledGroundOptionsPrecision value );
	
	external bool get updatable;
	external set updatable( bool value );
}

@JS()
@anonymous
class GroundBuilderCreateTiledGroundOptionsSubdivisions {
	
	external factory GroundBuilderCreateTiledGroundOptionsSubdivisions({num w, num h});
	
	external num get w;
	external set w( num value );
	
	external num get h;
	external set h( num value );
}

@JS()
@anonymous
class GroundBuilderCreateTiledGroundOptionsPrecision {
	
	external factory GroundBuilderCreateTiledGroundOptionsPrecision({num w, num h});
	
	external num get w;
	external set w( num value );
	
	external num get h;
	external set h( num value );
}

@JS()
@anonymous
class GroundBuilderCreateGroundFromHeightMapOptions {
	
	external factory GroundBuilderCreateGroundFromHeightMapOptions({num width, num height, num subdivisions, num minHeight, num maxHeight, Color3 colorFilter, num alphaFilter, bool updatable, void Function(GroundMesh mesh) onReady});
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get subdivisions;
	external set subdivisions( num value );
	
	external num get minHeight;
	external set minHeight( num value );
	
	external num get maxHeight;
	external set maxHeight( num value );
	
	external Color3 get colorFilter;
	external set colorFilter( Color3 value );
	
	external num get alphaFilter;
	external set alphaFilter( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external void Function(GroundMesh mesh) get onReady;
	external set onReady( void Function(GroundMesh mesh) value );
}

@JS()
@anonymous
class TorusBuilderCreateTorusOptions {
	
	external factory TorusBuilderCreateTorusOptions({num diameter, num thickness, num tessellation, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get diameter;
	external set diameter( num value );
	
	external num get thickness;
	external set thickness( num value );
	
	external num get tessellation;
	external set tessellation( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class CylinderBuilderCreateCylinderOptions {
	
	external factory CylinderBuilderCreateCylinderOptions({num height, num diameterTop, num diameterBottom, num diameter, num tessellation, num subdivisions, num arc, List<Color4> faceColors, List<Vector4> faceUV, bool updatable, bool hasRings, bool enclose, num cap, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get height;
	external set height( num value );
	
	external num get diameterTop;
	external set diameterTop( num value );
	
	external num get diameterBottom;
	external set diameterBottom( num value );
	
	external num get diameter;
	external set diameter( num value );
	
	external num get tessellation;
	external set tessellation( num value );
	
	external num get subdivisions;
	external set subdivisions( num value );
	
	external num get arc;
	external set arc( num value );
	
	external List<Color4> get faceColors;
	external set faceColors( List<Color4> value );
	
	external List<Vector4> get faceUV;
	external set faceUV( List<Vector4> value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external bool get hasRings;
	external set hasRings( bool value );
	
	external bool get enclose;
	external set enclose( bool value );
	
	external num get cap;
	external set cap( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class WebXRFeaturesManagerDisableFeatureFeatureName {
	
	external factory WebXRFeaturesManagerDisableFeatureFeatureName({String Name});
	
	external String get Name;
	external set Name( String value );
}

@JS()
@anonymous
class WebXRFeaturesManagerEnableFeatureFeatureName {
	
	external factory WebXRFeaturesManagerEnableFeatureFeatureName({String Name});
	
	external String get Name;
	external set Name( String value );
}

@JS()
@anonymous
class WebXRControllerComponentOnAxisValueChangedObservable {
	
	external factory WebXRControllerComponentOnAxisValueChangedObservable({num x, num y});
	
	external num get x;
	external set x( num value );
	
	external num get y;
	external set y( num value );
}

@JS()
@anonymous
class ISceneLoaderPluginAsyncImportMeshAsync {
	
	external factory ISceneLoaderPluginAsyncImportMeshAsync({List<AbstractMesh> meshes, List<IParticleSystem> particleSystems, List<Skeleton> skeletons, List<AnimationGroup> animationGroups});
	
	external List<AbstractMesh> get meshes;
	external set meshes( List<AbstractMesh> value );
	
	external List<IParticleSystem> get particleSystems;
	external set particleSystems( List<IParticleSystem> value );
	
	external List<Skeleton> get skeletons;
	external set skeletons( List<Skeleton> value );
	
	external List<AnimationGroup> get animationGroups;
	external set animationGroups( List<AnimationGroup> value );
}

@JS()
@anonymous
class SceneLoaderImportMeshAsync {
	
	external factory SceneLoaderImportMeshAsync({List<AbstractMesh> meshes, List<IParticleSystem> particleSystems, List<Skeleton> skeletons, List<AnimationGroup> animationGroups});
	
	external List<AbstractMesh> get meshes;
	external set meshes( List<AbstractMesh> value );
	
	external List<IParticleSystem> get particleSystems;
	external set particleSystems( List<IParticleSystem> value );
	
	external List<Skeleton> get skeletons;
	external set skeletons( List<Skeleton> value );
	
	external List<AnimationGroup> get animationGroups;
	external set animationGroups( List<AnimationGroup> value );
}

@JS()
@anonymous
class IMinimalMotionControllerObjectButtons {
	
	external factory IMinimalMotionControllerObjectButtons({num value, bool touched, bool pressed});
	
	external num get value;
	external set value( num value );
	
	external bool get touched;
	external set touched( bool value );
	
	external bool get pressed;
	external set pressed( bool value );
}

@JS()
@anonymous
class SphereBuilderCreateSphereOptions {
	
	external factory SphereBuilderCreateSphereOptions({num segments, num diameter, num diameterX, num diameterY, num diameterZ, num arc, num slice, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, bool updatable});
	
	external num get segments;
	external set segments( num value );
	
	external num get diameter;
	external set diameter( num value );
	
	external num get diameterX;
	external set diameterX( num value );
	
	external num get diameterY;
	external set diameterY( num value );
	
	external num get diameterZ;
	external set diameterZ( num value );
	
	external num get arc;
	external set arc( num value );
	
	external num get slice;
	external set slice( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external bool get updatable;
	external set updatable( bool value );
}

@JS()
@anonymous
class LinesBuilderCreateLineSystemOptions {
	
	external factory LinesBuilderCreateLineSystemOptions({List<List<Vector3>> lines, bool updatable, LinesMesh instance, List<List<Color4>> colors, bool useVertexAlpha});
	
	external List<List<Vector3>> get lines;
	external set lines( List<List<Vector3>> value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external LinesMesh get instance;
	external set instance( LinesMesh value );
	
	external List<List<Color4>> get colors;
	external set colors( List<List<Color4>> value );
	
	external bool get useVertexAlpha;
	external set useVertexAlpha( bool value );
}

@JS()
@anonymous
class LinesBuilderCreateLinesOptions {
	
	external factory LinesBuilderCreateLinesOptions({List<Vector3> points, bool updatable, LinesMesh instance, List<Color4> colors, bool useVertexAlpha});
	
	external List<Vector3> get points;
	external set points( List<Vector3> value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external LinesMesh get instance;
	external set instance( LinesMesh value );
	
	external List<Color4> get colors;
	external set colors( List<Color4> value );
	
	external bool get useVertexAlpha;
	external set useVertexAlpha( bool value );
}

@JS()
@anonymous
class LinesBuilderCreateDashedLinesOptions {
	
	external factory LinesBuilderCreateDashedLinesOptions({List<Vector3> points, num dashSize, num gapSize, num dashNb, bool updatable, LinesMesh instance, bool useVertexAlpha});
	
	external List<Vector3> get points;
	external set points( List<Vector3> value );
	
	external num get dashSize;
	external set dashSize( num value );
	
	external num get gapSize;
	external set gapSize( num value );
	
	external num get dashNb;
	external set dashNb( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external LinesMesh get instance;
	external set instance( LinesMesh value );
	
	external bool get useVertexAlpha;
	external set useVertexAlpha( bool value );
}

@JS()
@anonymous
class IWebXRTeleportationOptionsDefaultTargetMeshOptions {
	
	external factory IWebXRTeleportationOptionsDefaultTargetMeshOptions({String teleportationFillColor, String teleportationBorderColor, bool disableAnimation, bool disableLighting, Material torusArrowMaterial});
	
	external String get teleportationFillColor;
	external set teleportationFillColor( String value );
	
	external String get teleportationBorderColor;
	external set teleportationBorderColor( String value );
	
	external bool get disableAnimation;
	external set disableAnimation( bool value );
	
	external bool get disableLighting;
	external set disableLighting( bool value );
	
	external Material get torusArrowMaterial;
	external set torusArrowMaterial( Material value );
}

@JS()
@anonymous
class VRExperienceHelperOnMeshSelectedWithController {
	
	external factory VRExperienceHelperOnMeshSelectedWithController({AbstractMesh mesh, WebVRController controller});
	
	external AbstractMesh get mesh;
	external set mesh( AbstractMesh value );
	
	external WebVRController get controller;
	external set controller( WebVRController value );
}

@JS()
@anonymous
class PlaneDragGizmoOnSnapObservable {
	
	external factory PlaneDragGizmoOnSnapObservable({num snapDistance});
	
	external num get snapDistance;
	external set snapDistance( num value );
}

@JS()
@anonymous
class AxisDragGizmoOnSnapObservable {
	
	external factory AxisDragGizmoOnSnapObservable({num snapDistance});
	
	external num get snapDistance;
	external set snapDistance( num value );
}

@JS()
@anonymous
class BoxBuilderCreateBoxOptions {
	
	external factory BoxBuilderCreateBoxOptions({num size, num width, num height, num depth, List<Vector4> faceUV, List<Color4> faceColors, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, bool wrap, num topBaseAt, num bottomBaseAt, bool updatable});
	
	external num get size;
	external set size( num value );
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get depth;
	external set depth( num value );
	
	external List<Vector4> get faceUV;
	external set faceUV( List<Vector4> value );
	
	external List<Color4> get faceColors;
	external set faceColors( List<Color4> value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external bool get wrap;
	external set wrap( bool value );
	
	external num get topBaseAt;
	external set topBaseAt( num value );
	
	external num get bottomBaseAt;
	external set bottomBaseAt( num value );
	
	external bool get updatable;
	external set updatable( bool value );
}

@JS()
@anonymous
class NativeEngineCreateRenderTargetTextureSize {
	
	external factory NativeEngineCreateRenderTargetTextureSize({num width, num height});
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
}

@JS()
@anonymous
class PolyhedronBuilderCreatePolyhedronOptions {
	
	external factory PolyhedronBuilderCreatePolyhedronOptions({num type, num size, num sizeX, num sizeY, num sizeZ, dynamic custom, List<Vector4> faceUV, List<Color4> faceColors, bool flat, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get type;
	external set type( num value );
	
	external num get size;
	external set size( num value );
	
	external num get sizeX;
	external set sizeX( num value );
	
	external num get sizeY;
	external set sizeY( num value );
	
	external num get sizeZ;
	external set sizeZ( num value );
	
	external dynamic get custom;
	external set custom( dynamic value );
	
	external List<Vector4> get faceUV;
	external set faceUV( List<Vector4> value );
	
	external List<Color4> get faceColors;
	external set faceColors( List<Color4> value );
	
	external bool get flat;
	external set flat( bool value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class AxisScaleGizmoOnSnapObservable {
	
	external factory AxisScaleGizmoOnSnapObservable({num snapDistance});
	
	external num get snapDistance;
	external set snapDistance( num value );
}

@JS()
@anonymous
class PlaneRotationGizmoOnSnapObservable {
	
	external factory PlaneRotationGizmoOnSnapObservable({num snapDistance});
	
	external num get snapDistance;
	external set snapDistance( num value );
}

@JS()
@anonymous
class GizmoManagerGizmos {
	
	external factory GizmoManagerGizmos({PositionGizmo positionGizmo, RotationGizmo rotationGizmo, ScaleGizmo scaleGizmo, BoundingBoxGizmo boundingBoxGizmo});
	
	external PositionGizmo get positionGizmo;
	external set positionGizmo( PositionGizmo value );
	
	external RotationGizmo get rotationGizmo;
	external set rotationGizmo( RotationGizmo value );
	
	external ScaleGizmo get scaleGizmo;
	external set scaleGizmo( ScaleGizmo value );
	
	external BoundingBoxGizmo get boundingBoxGizmo;
	external set boundingBoxGizmo( BoundingBoxGizmo value );
}

@JS()
@anonymous
class HemisphereBuilderCreateHemisphereOptions {
	
	external factory HemisphereBuilderCreateHemisphereOptions({num segments, num diameter, num sideOrientation});
	
	external num get segments;
	external set segments( num value );
	
	external num get diameter;
	external set diameter( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
}

@JS()
@anonymous
class EnvironmentHelperOnErrorObservable {
	
	external factory EnvironmentHelperOnErrorObservable({String message, dynamic exception});
	
	external String get message;
	external set message( String value );
	
	external dynamic get exception;
	external set exception( dynamic value );
}

@JS()
@anonymous
class PhotoDomeConstructorOptions {
	
	external factory PhotoDomeConstructorOptions({num resolution, num size, bool useDirectMapping, bool faceForward});
	
	external num get resolution;
	external set resolution( num value );
	
	external num get size;
	external set size( num value );
	
	external bool get useDirectMapping;
	external set useDirectMapping( bool value );
	
	external bool get faceForward;
	external set faceForward( bool value );
}

@JS()
@anonymous
class VideoDomeConstructorOptions {
	
	external factory VideoDomeConstructorOptions({num resolution, bool clickToPlay, bool autoPlay, bool loop, num size, String poster, bool faceForward, bool useDirectMapping, bool halfDomeMode});
	
	external num get resolution;
	external set resolution( num value );
	
	external bool get clickToPlay;
	external set clickToPlay( bool value );
	
	external bool get autoPlay;
	external set autoPlay( bool value );
	
	external bool get loop;
	external set loop( bool value );
	
	external num get size;
	external set size( num value );
	
	external String get poster;
	external set poster( String value );
	
	external bool get faceForward;
	external set faceForward( bool value );
	
	external bool get useDirectMapping;
	external set useDirectMapping( bool value );
	
	external bool get halfDomeMode;
	external set halfDomeMode( bool value );
}

@JS()
@anonymous
class MinMaxReducerOnAfterReductionPerformed {
	
	external factory MinMaxReducerOnAfterReductionPerformed({num min, num max});
	
	external num get min;
	external set min( num value );
	
	external num get max;
	external set max( num value );
}

@JS()
@anonymous
class RibbonBuilderCreateRibbonOptions {
	
	external factory RibbonBuilderCreateRibbonOptions({List<List<Vector3>> pathArray, bool closeArray, bool closePath, num offset, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, Mesh instance, bool invertUV, List<Vector2> uvs, List<Color4> colors});
	
	external List<List<Vector3>> get pathArray;
	external set pathArray( List<List<Vector3>> value );
	
	external bool get closeArray;
	external set closeArray( bool value );
	
	external bool get closePath;
	external set closePath( bool value );
	
	external num get offset;
	external set offset( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external Mesh get instance;
	external set instance( Mesh value );
	
	external bool get invertUV;
	external set invertUV( bool value );
	
	external List<Vector2> get uvs;
	external set uvs( List<Vector2> value );
	
	external List<Color4> get colors;
	external set colors( List<Color4> value );
}

@JS()
@anonymous
class ShapeBuilderExtrudeShapeOptions {
	
	external factory ShapeBuilderExtrudeShapeOptions({List<Vector3> shape, List<Vector3> path, num scale, num rotation, num cap, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, Mesh instance, bool invertUV});
	
	external List<Vector3> get shape;
	external set shape( List<Vector3> value );
	
	external List<Vector3> get path;
	external set path( List<Vector3> value );
	
	external num get scale;
	external set scale( num value );
	
	external num get rotation;
	external set rotation( num value );
	
	external num get cap;
	external set cap( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external Mesh get instance;
	external set instance( Mesh value );
	
	external bool get invertUV;
	external set invertUV( bool value );
}

@JS()
@anonymous
class ShapeBuilderExtrudeShapeCustomOptions {
	
	external factory ShapeBuilderExtrudeShapeCustomOptions({List<Vector3> shape, List<Vector3> path, dynamic scaleFunction, dynamic rotationFunction, bool ribbonCloseArray, bool ribbonClosePath, num cap, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, Mesh instance, bool invertUV});
	
	external List<Vector3> get shape;
	external set shape( List<Vector3> value );
	
	external List<Vector3> get path;
	external set path( List<Vector3> value );
	
	external dynamic get scaleFunction;
	external set scaleFunction( dynamic value );
	
	external dynamic get rotationFunction;
	external set rotationFunction( dynamic value );
	
	external bool get ribbonCloseArray;
	external set ribbonCloseArray( bool value );
	
	external bool get ribbonClosePath;
	external set ribbonClosePath( bool value );
	
	external num get cap;
	external set cap( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external Mesh get instance;
	external set instance( Mesh value );
	
	external bool get invertUV;
	external set invertUV( bool value );
}

@JS()
@anonymous
class BasisFileInfoImages {
	
	external factory BasisFileInfoImages({List<BasisFileInfoImagesLevels> levels});
	
	external List<BasisFileInfoImagesLevels> get levels;
	external set levels( List<BasisFileInfoImagesLevels> value );
}

@JS()
@anonymous
class BasisFileInfoImagesLevels {
	
	external factory BasisFileInfoImagesLevels({num width, num height, dynamic transcodedPixels});
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external dynamic get transcodedPixels;
	external set transcodedPixels( dynamic value );
}

@JS()
@anonymous
class BasisTranscodeConfigurationSupportedCompressionFormats {
	
	external factory BasisTranscodeConfigurationSupportedCompressionFormats({bool etc1, bool s3tc, bool pvrtc, bool etc2});
	
	external bool get etc1;
	external set etc1( bool value );
	
	external bool get s3tc;
	external set s3tc( bool value );
	
	external bool get pvrtc;
	external set pvrtc( bool value );
	
	external bool get etc2;
	external set etc2( bool value );
}

@JS()
@anonymous
class NodeMaterialBuildStateSharedDataHints {
	
	external factory NodeMaterialBuildStateSharedDataHints({bool needWorldViewMatrix, bool needWorldViewProjectionMatrix, bool needAlphaBlending, bool needAlphaTesting});
	
	external bool get needWorldViewMatrix;
	external set needWorldViewMatrix( bool value );
	
	external bool get needWorldViewProjectionMatrix;
	external set needWorldViewProjectionMatrix( bool value );
	
	external bool get needAlphaBlending;
	external set needAlphaBlending( bool value );
	
	external bool get needAlphaTesting;
	external set needAlphaTesting( bool value );
}

@JS()
@anonymous
class NodeMaterialBuildStateSharedDataChecks {
	
	external factory NodeMaterialBuildStateSharedDataChecks({bool emitVertex, bool emitFragment, List<NodeMaterialConnectionPoint> notConnectedNonOptionalInputs});
	
	external bool get emitVertex;
	external set emitVertex( bool value );
	
	external bool get emitFragment;
	external set emitFragment( bool value );
	
	external List<NodeMaterialConnectionPoint> get notConnectedNonOptionalInputs;
	external set notConnectedNonOptionalInputs( List<NodeMaterialConnectionPoint> value );
}

@JS()
@anonymous
class NodeMaterialBlockConnectToOptions {
	
	external factory NodeMaterialBlockConnectToOptions({String input, String output, String outputSwizzle});
	
	external String get input;
	external set input( String value );
	
	external String get output;
	external set output( String value );
	
	external String get outputSwizzle;
	external set outputSwizzle( String value );
}

@JS()
@anonymous
class IDracoCompressionConfigurationDecoder {
	
	external factory IDracoCompressionConfigurationDecoder({String wasmUrl, String wasmBinaryUrl, String fallbackUrl});
	
	external String get wasmUrl;
	external set wasmUrl( String value );
	
	external String get wasmBinaryUrl;
	external set wasmBinaryUrl( String value );
	
	external String get fallbackUrl;
	external set fallbackUrl( String value );
}

@JS()
@anonymous
class TiledBoxBuilderCreateTiledBoxOptions {
	
	external factory TiledBoxBuilderCreateTiledBoxOptions({num pattern, num width, num height, num depth, num tileSize, num tileWidth, num tileHeight, num alignHorizontal, num alignVertical, List<Vector4> faceUV, List<Color4> faceColors, num sideOrientation, bool updatable});
	
	external num get pattern;
	external set pattern( num value );
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get depth;
	external set depth( num value );
	
	external num get tileSize;
	external set tileSize( num value );
	
	external num get tileWidth;
	external set tileWidth( num value );
	
	external num get tileHeight;
	external set tileHeight( num value );
	
	external num get alignHorizontal;
	external set alignHorizontal( num value );
	
	external num get alignVertical;
	external set alignVertical( num value );
	
	external List<Vector4> get faceUV;
	external set faceUV( List<Vector4> value );
	
	external List<Color4> get faceColors;
	external set faceColors( List<Color4> value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external bool get updatable;
	external set updatable( bool value );
}

@JS()
@anonymous
class TorusKnotBuilderCreateTorusKnotOptions {
	
	external factory TorusKnotBuilderCreateTorusKnotOptions({num radius, num tube, num radialSegments, num tubularSegments, num p, num q, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get radius;
	external set radius( num value );
	
	external num get tube;
	external set tube( num value );
	
	external num get radialSegments;
	external set radialSegments( num value );
	
	external num get tubularSegments;
	external set tubularSegments( num value );
	
	external num get p;
	external set p( num value );
	
	external num get q;
	external set q( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class PolygonBuilderCreatePolygonOptions {
	
	external factory PolygonBuilderCreatePolygonOptions({List<Vector3> shape, List<List<Vector3>> holes, num depth, List<Vector4> faceUV, List<Color4> faceColors, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external List<Vector3> get shape;
	external set shape( List<Vector3> value );
	
	external List<List<Vector3>> get holes;
	external set holes( List<List<Vector3>> value );
	
	external num get depth;
	external set depth( num value );
	
	external List<Vector4> get faceUV;
	external set faceUV( List<Vector4> value );
	
	external List<Color4> get faceColors;
	external set faceColors( List<Color4> value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class PolygonBuilderExtrudePolygonOptions {
	
	external factory PolygonBuilderExtrudePolygonOptions({List<Vector3> shape, List<List<Vector3>> holes, num depth, List<Vector4> faceUV, List<Color4> faceColors, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external List<Vector3> get shape;
	external set shape( List<Vector3> value );
	
	external List<List<Vector3>> get holes;
	external set holes( List<List<Vector3>> value );
	
	external num get depth;
	external set depth( num value );
	
	external List<Vector4> get faceUV;
	external set faceUV( List<Vector4> value );
	
	external List<Color4> get faceColors;
	external set faceColors( List<Color4> value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class LatheBuilderCreateLatheOptions {
	
	external factory LatheBuilderCreateLatheOptions({List<Vector3> shape, num radius, num tessellation, num clip, num arc, bool closed, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, num cap, bool invertUV});
	
	external List<Vector3> get shape;
	external set shape( List<Vector3> value );
	
	external num get radius;
	external set radius( num value );
	
	external num get tessellation;
	external set tessellation( num value );
	
	external num get clip;
	external set clip( num value );
	
	external num get arc;
	external set arc( num value );
	
	external bool get closed;
	external set closed( bool value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external num get cap;
	external set cap( num value );
	
	external bool get invertUV;
	external set invertUV( bool value );
}

@JS()
@anonymous
class TiledPlaneBuilderCreateTiledPlaneOptions {
	
	external factory TiledPlaneBuilderCreateTiledPlaneOptions({num pattern, num tileSize, num tileWidth, num tileHeight, num size, num width, num height, num alignHorizontal, num alignVertical, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, bool updatable});
	
	external num get pattern;
	external set pattern( num value );
	
	external num get tileSize;
	external set tileSize( num value );
	
	external num get tileWidth;
	external set tileWidth( num value );
	
	external num get tileHeight;
	external set tileHeight( num value );
	
	external num get size;
	external set size( num value );
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get alignHorizontal;
	external set alignHorizontal( num value );
	
	external num get alignVertical;
	external set alignVertical( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external bool get updatable;
	external set updatable( bool value );
}

@JS()
@anonymous
class TubeBuilderCreateTubeOptions {
	
	external factory TubeBuilderCreateTubeOptions({List<Vector3> path, num radius, num tessellation, num Function(num i, num distance) radiusFunction, num cap, num arc, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, Mesh instance, bool invertUV});
	
	external List<Vector3> get path;
	external set path( List<Vector3> value );
	
	external num get radius;
	external set radius( num value );
	
	external num get tessellation;
	external set tessellation( num value );
	
	external num Function(num i, num distance) get radiusFunction;
	external set radiusFunction( num Function(num i, num distance) value );
	
	external num get cap;
	external set cap( num value );
	
	external num get arc;
	external set arc( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external Mesh get instance;
	external set instance( Mesh value );
	
	external bool get invertUV;
	external set invertUV( bool value );
}

@JS()
@anonymous
class IcoSphereBuilderCreateIcoSphereOptions {
	
	external factory IcoSphereBuilderCreateIcoSphereOptions({num radius, num radiusX, num radiusY, num radiusZ, bool flat, num subdivisions, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, bool updatable});
	
	external num get radius;
	external set radius( num value );
	
	external num get radiusX;
	external set radiusX( num value );
	
	external num get radiusY;
	external set radiusY( num value );
	
	external num get radiusZ;
	external set radiusZ( num value );
	
	external bool get flat;
	external set flat( bool value );
	
	external num get subdivisions;
	external set subdivisions( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external bool get updatable;
	external set updatable( bool value );
}

@JS()
@anonymous
class DecalBuilderCreateDecalOptions {
	
	external factory DecalBuilderCreateDecalOptions({Vector3 position, Vector3 normal, Vector3 size, num angle});
	
	external Vector3 get position;
	external set position( Vector3 value );
	
	external Vector3 get normal;
	external set normal( Vector3 value );
	
	external Vector3 get size;
	external set size( Vector3 value );
	
	external num get angle;
	external set angle( num value );
}

@JS()
@anonymous
class MeshBuilderCreateBoxOptions {
	
	external factory MeshBuilderCreateBoxOptions({num size, num width, num height, num depth, List<Vector4> faceUV, List<Color4> faceColors, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, bool updatable});
	
	external num get size;
	external set size( num value );
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get depth;
	external set depth( num value );
	
	external List<Vector4> get faceUV;
	external set faceUV( List<Vector4> value );
	
	external List<Color4> get faceColors;
	external set faceColors( List<Color4> value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external bool get updatable;
	external set updatable( bool value );
}

@JS()
@anonymous
class MeshBuilderCreateTiledBoxOptions {
	
	external factory MeshBuilderCreateTiledBoxOptions({num pattern, num size, num width, num height, num depth, num tileSize, num tileWidth, num tileHeight, List<Vector4> faceUV, List<Color4> faceColors, num alignHorizontal, num alignVertical, num sideOrientation, bool updatable});
	
	external num get pattern;
	external set pattern( num value );
	
	external num get size;
	external set size( num value );
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get depth;
	external set depth( num value );
	
	external num get tileSize;
	external set tileSize( num value );
	
	external num get tileWidth;
	external set tileWidth( num value );
	
	external num get tileHeight;
	external set tileHeight( num value );
	
	external List<Vector4> get faceUV;
	external set faceUV( List<Vector4> value );
	
	external List<Color4> get faceColors;
	external set faceColors( List<Color4> value );
	
	external num get alignHorizontal;
	external set alignHorizontal( num value );
	
	external num get alignVertical;
	external set alignVertical( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external bool get updatable;
	external set updatable( bool value );
}

@JS()
@anonymous
class MeshBuilderCreateSphereOptions {
	
	external factory MeshBuilderCreateSphereOptions({num segments, num diameter, num diameterX, num diameterY, num diameterZ, num arc, num slice, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, bool updatable});
	
	external num get segments;
	external set segments( num value );
	
	external num get diameter;
	external set diameter( num value );
	
	external num get diameterX;
	external set diameterX( num value );
	
	external num get diameterY;
	external set diameterY( num value );
	
	external num get diameterZ;
	external set diameterZ( num value );
	
	external num get arc;
	external set arc( num value );
	
	external num get slice;
	external set slice( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external bool get updatable;
	external set updatable( bool value );
}

@JS()
@anonymous
class MeshBuilderCreateDiscOptions {
	
	external factory MeshBuilderCreateDiscOptions({num radius, num tessellation, num arc, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get radius;
	external set radius( num value );
	
	external num get tessellation;
	external set tessellation( num value );
	
	external num get arc;
	external set arc( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class MeshBuilderCreateIcoSphereOptions {
	
	external factory MeshBuilderCreateIcoSphereOptions({num radius, num radiusX, num radiusY, num radiusZ, bool flat, num subdivisions, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, bool updatable});
	
	external num get radius;
	external set radius( num value );
	
	external num get radiusX;
	external set radiusX( num value );
	
	external num get radiusY;
	external set radiusY( num value );
	
	external num get radiusZ;
	external set radiusZ( num value );
	
	external bool get flat;
	external set flat( bool value );
	
	external num get subdivisions;
	external set subdivisions( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external bool get updatable;
	external set updatable( bool value );
}

@JS()
@anonymous
class MeshBuilderCreateRibbonOptions {
	
	external factory MeshBuilderCreateRibbonOptions({List<List<Vector3>> pathArray, bool closeArray, bool closePath, num offset, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, Mesh instance, bool invertUV, List<Vector2> uvs, List<Color4> colors});
	
	external List<List<Vector3>> get pathArray;
	external set pathArray( List<List<Vector3>> value );
	
	external bool get closeArray;
	external set closeArray( bool value );
	
	external bool get closePath;
	external set closePath( bool value );
	
	external num get offset;
	external set offset( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external Mesh get instance;
	external set instance( Mesh value );
	
	external bool get invertUV;
	external set invertUV( bool value );
	
	external List<Vector2> get uvs;
	external set uvs( List<Vector2> value );
	
	external List<Color4> get colors;
	external set colors( List<Color4> value );
}

@JS()
@anonymous
class MeshBuilderCreateCylinderOptions {
	
	external factory MeshBuilderCreateCylinderOptions({num height, num diameterTop, num diameterBottom, num diameter, num tessellation, num subdivisions, num arc, List<Color4> faceColors, List<Vector4> faceUV, bool updatable, bool hasRings, bool enclose, num cap, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get height;
	external set height( num value );
	
	external num get diameterTop;
	external set diameterTop( num value );
	
	external num get diameterBottom;
	external set diameterBottom( num value );
	
	external num get diameter;
	external set diameter( num value );
	
	external num get tessellation;
	external set tessellation( num value );
	
	external num get subdivisions;
	external set subdivisions( num value );
	
	external num get arc;
	external set arc( num value );
	
	external List<Color4> get faceColors;
	external set faceColors( List<Color4> value );
	
	external List<Vector4> get faceUV;
	external set faceUV( List<Vector4> value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external bool get hasRings;
	external set hasRings( bool value );
	
	external bool get enclose;
	external set enclose( bool value );
	
	external num get cap;
	external set cap( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class MeshBuilderCreateTorusOptions {
	
	external factory MeshBuilderCreateTorusOptions({num diameter, num thickness, num tessellation, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get diameter;
	external set diameter( num value );
	
	external num get thickness;
	external set thickness( num value );
	
	external num get tessellation;
	external set tessellation( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class MeshBuilderCreateTorusKnotOptions {
	
	external factory MeshBuilderCreateTorusKnotOptions({num radius, num tube, num radialSegments, num tubularSegments, num p, num q, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get radius;
	external set radius( num value );
	
	external num get tube;
	external set tube( num value );
	
	external num get radialSegments;
	external set radialSegments( num value );
	
	external num get tubularSegments;
	external set tubularSegments( num value );
	
	external num get p;
	external set p( num value );
	
	external num get q;
	external set q( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class MeshBuilderCreateLineSystemOptions {
	
	external factory MeshBuilderCreateLineSystemOptions({List<List<Vector3>> lines, bool updatable, LinesMesh instance, List<List<Color4>> colors, bool useVertexAlpha});
	
	external List<List<Vector3>> get lines;
	external set lines( List<List<Vector3>> value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external LinesMesh get instance;
	external set instance( LinesMesh value );
	
	external List<List<Color4>> get colors;
	external set colors( List<List<Color4>> value );
	
	external bool get useVertexAlpha;
	external set useVertexAlpha( bool value );
}

@JS()
@anonymous
class MeshBuilderCreateLinesOptions {
	
	external factory MeshBuilderCreateLinesOptions({List<Vector3> points, bool updatable, LinesMesh instance, List<Color4> colors, bool useVertexAlpha});
	
	external List<Vector3> get points;
	external set points( List<Vector3> value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external LinesMesh get instance;
	external set instance( LinesMesh value );
	
	external List<Color4> get colors;
	external set colors( List<Color4> value );
	
	external bool get useVertexAlpha;
	external set useVertexAlpha( bool value );
}

@JS()
@anonymous
class MeshBuilderCreateDashedLinesOptions {
	
	external factory MeshBuilderCreateDashedLinesOptions({List<Vector3> points, num dashSize, num gapSize, num dashNb, bool updatable, LinesMesh instance});
	
	external List<Vector3> get points;
	external set points( List<Vector3> value );
	
	external num get dashSize;
	external set dashSize( num value );
	
	external num get gapSize;
	external set gapSize( num value );
	
	external num get dashNb;
	external set dashNb( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external LinesMesh get instance;
	external set instance( LinesMesh value );
}

@JS()
@anonymous
class MeshBuilderExtrudeShapeOptions {
	
	external factory MeshBuilderExtrudeShapeOptions({List<Vector3> shape, List<Vector3> path, num scale, num rotation, num cap, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, Mesh instance, bool invertUV});
	
	external List<Vector3> get shape;
	external set shape( List<Vector3> value );
	
	external List<Vector3> get path;
	external set path( List<Vector3> value );
	
	external num get scale;
	external set scale( num value );
	
	external num get rotation;
	external set rotation( num value );
	
	external num get cap;
	external set cap( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external Mesh get instance;
	external set instance( Mesh value );
	
	external bool get invertUV;
	external set invertUV( bool value );
}

@JS()
@anonymous
class MeshBuilderExtrudeShapeCustomOptions {
	
	external factory MeshBuilderExtrudeShapeCustomOptions({List<Vector3> shape, List<Vector3> path, dynamic scaleFunction, dynamic rotationFunction, bool ribbonCloseArray, bool ribbonClosePath, num cap, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, Mesh instance, bool invertUV});
	
	external List<Vector3> get shape;
	external set shape( List<Vector3> value );
	
	external List<Vector3> get path;
	external set path( List<Vector3> value );
	
	external dynamic get scaleFunction;
	external set scaleFunction( dynamic value );
	
	external dynamic get rotationFunction;
	external set rotationFunction( dynamic value );
	
	external bool get ribbonCloseArray;
	external set ribbonCloseArray( bool value );
	
	external bool get ribbonClosePath;
	external set ribbonClosePath( bool value );
	
	external num get cap;
	external set cap( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external Mesh get instance;
	external set instance( Mesh value );
	
	external bool get invertUV;
	external set invertUV( bool value );
}

@JS()
@anonymous
class MeshBuilderCreateLatheOptions {
	
	external factory MeshBuilderCreateLatheOptions({List<Vector3> shape, num radius, num tessellation, num clip, num arc, bool closed, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, num cap, bool invertUV});
	
	external List<Vector3> get shape;
	external set shape( List<Vector3> value );
	
	external num get radius;
	external set radius( num value );
	
	external num get tessellation;
	external set tessellation( num value );
	
	external num get clip;
	external set clip( num value );
	
	external num get arc;
	external set arc( num value );
	
	external bool get closed;
	external set closed( bool value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external num get cap;
	external set cap( num value );
	
	external bool get invertUV;
	external set invertUV( bool value );
}

@JS()
@anonymous
class MeshBuilderCreateTiledPlaneOptions {
	
	external factory MeshBuilderCreateTiledPlaneOptions({num pattern, num tileSize, num tileWidth, num tileHeight, num size, num width, num height, num alignHorizontal, num alignVertical, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, bool updatable});
	
	external num get pattern;
	external set pattern( num value );
	
	external num get tileSize;
	external set tileSize( num value );
	
	external num get tileWidth;
	external set tileWidth( num value );
	
	external num get tileHeight;
	external set tileHeight( num value );
	
	external num get size;
	external set size( num value );
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get alignHorizontal;
	external set alignHorizontal( num value );
	
	external num get alignVertical;
	external set alignVertical( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external bool get updatable;
	external set updatable( bool value );
}

@JS()
@anonymous
class MeshBuilderCreatePlaneOptions {
	
	external factory MeshBuilderCreatePlaneOptions({num size, num width, num height, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, bool updatable, Plane sourcePlane});
	
	external num get size;
	external set size( num value );
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external Plane get sourcePlane;
	external set sourcePlane( Plane value );
}

@JS()
@anonymous
class MeshBuilderCreateGroundOptions {
	
	external factory MeshBuilderCreateGroundOptions({num width, num height, num subdivisions, num subdivisionsX, num subdivisionsY, bool updatable});
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get subdivisions;
	external set subdivisions( num value );
	
	external num get subdivisionsX;
	external set subdivisionsX( num value );
	
	external num get subdivisionsY;
	external set subdivisionsY( num value );
	
	external bool get updatable;
	external set updatable( bool value );
}

@JS()
@anonymous
class MeshBuilderCreateTiledGroundOptions {
	
	external factory MeshBuilderCreateTiledGroundOptions({num xmin, num zmin, num xmax, num zmax, MeshBuilderCreateTiledGroundOptionsSubdivisions subdivisions, MeshBuilderCreateTiledGroundOptionsPrecision precision, bool updatable});
	
	external num get xmin;
	external set xmin( num value );
	
	external num get zmin;
	external set zmin( num value );
	
	external num get xmax;
	external set xmax( num value );
	
	external num get zmax;
	external set zmax( num value );
	
	external MeshBuilderCreateTiledGroundOptionsSubdivisions get subdivisions;
	external set subdivisions( MeshBuilderCreateTiledGroundOptionsSubdivisions value );
	
	external MeshBuilderCreateTiledGroundOptionsPrecision get precision;
	external set precision( MeshBuilderCreateTiledGroundOptionsPrecision value );
	
	external bool get updatable;
	external set updatable( bool value );
}

@JS()
@anonymous
class MeshBuilderCreateTiledGroundOptionsSubdivisions {
	
	external factory MeshBuilderCreateTiledGroundOptionsSubdivisions({num w, num h});
	
	external num get w;
	external set w( num value );
	
	external num get h;
	external set h( num value );
}

@JS()
@anonymous
class MeshBuilderCreateTiledGroundOptionsPrecision {
	
	external factory MeshBuilderCreateTiledGroundOptionsPrecision({num w, num h});
	
	external num get w;
	external set w( num value );
	
	external num get h;
	external set h( num value );
}

@JS()
@anonymous
class MeshBuilderCreateGroundFromHeightMapOptions {
	
	external factory MeshBuilderCreateGroundFromHeightMapOptions({num width, num height, num subdivisions, num minHeight, num maxHeight, Color3 colorFilter, num alphaFilter, bool updatable, void Function(GroundMesh mesh) onReady});
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get subdivisions;
	external set subdivisions( num value );
	
	external num get minHeight;
	external set minHeight( num value );
	
	external num get maxHeight;
	external set maxHeight( num value );
	
	external Color3 get colorFilter;
	external set colorFilter( Color3 value );
	
	external num get alphaFilter;
	external set alphaFilter( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external void Function(GroundMesh mesh) get onReady;
	external set onReady( void Function(GroundMesh mesh) value );
}

@JS()
@anonymous
class MeshBuilderCreatePolygonOptions {
	
	external factory MeshBuilderCreatePolygonOptions({List<Vector3> shape, List<List<Vector3>> holes, num depth, List<Vector4> faceUV, List<Color4> faceColors, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external List<Vector3> get shape;
	external set shape( List<Vector3> value );
	
	external List<List<Vector3>> get holes;
	external set holes( List<List<Vector3>> value );
	
	external num get depth;
	external set depth( num value );
	
	external List<Vector4> get faceUV;
	external set faceUV( List<Vector4> value );
	
	external List<Color4> get faceColors;
	external set faceColors( List<Color4> value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class MeshBuilderExtrudePolygonOptions {
	
	external factory MeshBuilderExtrudePolygonOptions({List<Vector3> shape, List<List<Vector3>> holes, num depth, List<Vector4> faceUV, List<Color4> faceColors, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external List<Vector3> get shape;
	external set shape( List<Vector3> value );
	
	external List<List<Vector3>> get holes;
	external set holes( List<List<Vector3>> value );
	
	external num get depth;
	external set depth( num value );
	
	external List<Vector4> get faceUV;
	external set faceUV( List<Vector4> value );
	
	external List<Color4> get faceColors;
	external set faceColors( List<Color4> value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class MeshBuilderCreateTubeOptions {
	
	external factory MeshBuilderCreateTubeOptions({List<Vector3> path, num radius, num tessellation, num Function(num i, num distance) radiusFunction, num cap, num arc, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs, Mesh instance, bool invertUV});
	
	external List<Vector3> get path;
	external set path( List<Vector3> value );
	
	external num get radius;
	external set radius( num value );
	
	external num get tessellation;
	external set tessellation( num value );
	
	external num Function(num i, num distance) get radiusFunction;
	external set radiusFunction( num Function(num i, num distance) value );
	
	external num get cap;
	external set cap( num value );
	
	external num get arc;
	external set arc( num value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
	
	external Mesh get instance;
	external set instance( Mesh value );
	
	external bool get invertUV;
	external set invertUV( bool value );
}

@JS()
@anonymous
class MeshBuilderCreatePolyhedronOptions {
	
	external factory MeshBuilderCreatePolyhedronOptions({num type, num size, num sizeX, num sizeY, num sizeZ, dynamic custom, List<Vector4> faceUV, List<Color4> faceColors, bool flat, bool updatable, num sideOrientation, Vector4 frontUVs, Vector4 backUVs});
	
	external num get type;
	external set type( num value );
	
	external num get size;
	external set size( num value );
	
	external num get sizeX;
	external set sizeX( num value );
	
	external num get sizeY;
	external set sizeY( num value );
	
	external num get sizeZ;
	external set sizeZ( num value );
	
	external dynamic get custom;
	external set custom( dynamic value );
	
	external List<Vector4> get faceUV;
	external set faceUV( List<Vector4> value );
	
	external List<Color4> get faceColors;
	external set faceColors( List<Color4> value );
	
	external bool get flat;
	external set flat( bool value );
	
	external bool get updatable;
	external set updatable( bool value );
	
	external num get sideOrientation;
	external set sideOrientation( num value );
	
	external Vector4 get frontUVs;
	external set frontUVs( Vector4 value );
	
	external Vector4 get backUVs;
	external set backUVs( Vector4 value );
}

@JS()
@anonymous
class MeshBuilderCreateDecalOptions {
	
	external factory MeshBuilderCreateDecalOptions({Vector3 position, Vector3 normal, Vector3 size, num angle});
	
	external Vector3 get position;
	external set position( Vector3 value );
	
	external Vector3 get normal;
	external set normal( Vector3 value );
	
	external Vector3 get size;
	external set size( Vector3 value );
	
	external num get angle;
	external set angle( num value );
}

@JS()
@anonymous
class GPUParticleSystemConstructorOptions {
	
	external factory GPUParticleSystemConstructorOptions({num capacity, num randomTextureSize});
	
	external num get capacity;
	external set capacity( num value );
	
	external num get randomTextureSize;
	external set randomTextureSize( num value );
}

@JS()
@anonymous
class ParticleSystemSetSetEmitterAsSphereOptions {
	
	external factory ParticleSystemSetSetEmitterAsSphereOptions({num diameter, num segments, Color3 color});
	
	external num get diameter;
	external set diameter( num value );
	
	external num get segments;
	external set segments( num value );
	
	external Color3 get color;
	external set color( Color3 value );
}

@JS()
@anonymous
class PointsCloudSystemConstructorOptions {
	
	external factory PointsCloudSystemConstructorOptions({bool updatable});
	
	external bool get updatable;
	external set updatable( bool value );
}

@JS()
@anonymous
class PhysicsRadialExplosionEventOptionsSphere {
	
	external factory PhysicsRadialExplosionEventOptionsSphere({num segments, num diameter});
	
	external num get segments;
	external set segments( num value );
	
	external num get diameter;
	external set diameter( num value );
}

@JS()
@anonymous
class DepthOfFieldMergePostProcessOptionsDepthOfField {
	
	external factory DepthOfFieldMergePostProcessOptionsDepthOfField({PostProcess circleOfConfusion, List<PostProcess> blurSteps});
	
	external PostProcess get circleOfConfusion;
	external set circleOfConfusion( PostProcess value );
	
	external List<PostProcess> get blurSteps;
	external set blurSteps( List<PostProcess> value );
}

@JS()
@anonymous
class DepthOfFieldMergePostProcessOptionsBloom {
	
	external factory DepthOfFieldMergePostProcessOptionsBloom({PostProcess blurred, num weight});
	
	external PostProcess get blurred;
	external set blurred( PostProcess value );
	
	external num get weight;
	external set weight( num value );
}

@JS()
@anonymous
class VolumetricLightScatteringPostProcessAttachedNode {
	
	external factory VolumetricLightScatteringPostProcessAttachedNode({Vector3 position});
	
	external Vector3 get position;
	external set position( Vector3 value );
}

@JS()
@anonymous
class AbstractAssetTaskErrorObject {
	
	external factory AbstractAssetTaskErrorObject({String message, dynamic exception});
	
	external String get message;
	external set message( String value );
	
	external dynamic get exception;
	external set exception( dynamic value );
}

@JS()
@anonymous
class IWebXRBackgroundRemoverOptionsEnvironmentHelperRemovalFlags {
	
	external factory IWebXRBackgroundRemoverOptionsEnvironmentHelperRemovalFlags({bool skyBox, bool ground});
	
	external bool get skyBox;
	external set skyBox( bool value );
	
	external bool get ground;
	external set ground( bool value );
}

@JS()
@anonymous
class IWebXRControllerPhysicsOptionsHeadsetImpostorParams {
	
	external factory IWebXRControllerPhysicsOptionsHeadsetImpostorParams({num impostorType, dynamic impostorSize, num friction, num restitution});
	
	external num get impostorType;
	external set impostorType( num value );
	
	external dynamic get impostorSize;
	external set impostorSize( dynamic value );
	
	external num get friction;
	external set friction( num value );
	
	external num get restitution;
	external set restitution( num value );
}

@JS()
@anonymous
class IWebXRControllerPhysicsOptionsHeadsetImpostorParamsImpostorSize {
	
	external factory IWebXRControllerPhysicsOptionsHeadsetImpostorParamsImpostorSize({num width, num height, num depth});
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get depth;
	external set depth( num value );
}

@JS()
@anonymous
class IWebXRControllerPhysicsOptionsPhysicsProperties {
	
	external factory IWebXRControllerPhysicsOptionsPhysicsProperties({bool useControllerMesh, num impostorType, dynamic impostorSize, num friction, num restitution});
	
	external bool get useControllerMesh;
	external set useControllerMesh( bool value );
	
	external num get impostorType;
	external set impostorType( num value );
	
	external dynamic get impostorSize;
	external set impostorSize( dynamic value );
	
	external num get friction;
	external set friction( num value );
	
	external num get restitution;
	external set restitution( num value );
}

@JS()
@anonymous
class IWebXRControllerPhysicsOptionsPhysicsPropertiesImpostorSize {
	
	external factory IWebXRControllerPhysicsOptionsPhysicsPropertiesImpostorSize({num width, num height, num depth});
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get depth;
	external set depth( num value );
}

@JS()
@anonymous
class WebXRControllerPhysicsSetPhysicsPropertiesNewProperties {
	
	external factory WebXRControllerPhysicsSetPhysicsPropertiesNewProperties({num impostorType, dynamic impostorSize, num friction, num restitution});
	
	external num get impostorType;
	external set impostorType( num value );
	
	external dynamic get impostorSize;
	external set impostorSize( dynamic value );
	
	external num get friction;
	external set friction( num value );
	
	external num get restitution;
	external set restitution( num value );
}

@JS()
@anonymous
class WebXRControllerPhysicsSetPhysicsPropertiesNewPropertiesImpostorSize {
	
	external factory WebXRControllerPhysicsSetPhysicsPropertiesNewPropertiesImpostorSize({num width, num height, num depth});
	
	external num get width;
	external set width( num value );
	
	external num get height;
	external set height( num value );
	
	external num get depth;
	external set depth( num value );
}
