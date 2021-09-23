@JS("BABYLON.Debug")
library BABYLON.Debug;

import "dart:html" as HTML;
import "dart:js";
import "dart:math" as Math;
import "dart:typed_data";
import "dart:web_audio" as Audio;
import "dart:web_gl" as WebGL;

import "package:js/js.dart";

import "babylon.dart";
import "babylon_extensions.dart";
import "interop_globals.dart";
import "promise.dart";

export "interop_globals.dart";
export "promise.dart";

/// The Axes viewer will show 3 axes in a specific point in space
@JS()
class AxesViewer {
	
	/// Creates a new AxesViewer
	/// @param scene defines the hosting scene
	/// @param scaleLines defines a number used to scale line length (1 by default)
	/// @param renderingGroupId defines a number used to set the renderingGroupId of the meshes (2 by default)
	/// @param xAxis defines the node hierarchy used to render the x-axis
	/// @param yAxis defines the node hierarchy used to render the y-axis
	/// @param zAxis defines the node hierarchy used to render the z-axis
	external factory AxesViewer(Scene scene, [num? scaleLines, num? renderingGroupId, TransformNode? xAxis, TransformNode? yAxis, TransformNode? zAxis]);
	
	/// Gets the hosting scene
	external Scene get scene;
	external set scene(Scene value);
	
	/// Gets or sets a number used to scale line length
	external num get scaleLines;
	external set scaleLines(num value);
	
	/// Gets the node hierarchy used to render x-axis
	external TransformNode get xAxis;
	
	/// Gets the node hierarchy used to render y-axis
	external TransformNode get yAxis;
	
	/// Gets the node hierarchy used to render z-axis
	external TransformNode get zAxis;
	
	/// Force the viewer to update
	/// @param position defines the position of the viewer
	/// @param xaxis defines the x axis of the viewer
	/// @param yaxis defines the y axis of the viewer
	/// @param zaxis defines the z axis of the viewer
	external void update(Vector3 position, Vector3 xaxis, Vector3 yaxis, Vector3 zaxis);
	
	/// Creates an instance of this axes viewer.
	/// @returns a new axes viewer with instanced meshes
	external AxesViewer createInstance();
	
	/// Releases resources
	external void dispose();
}

/// The BoneAxesViewer will attach 3 axes to a specific bone of a specific mesh
/// @see demo here: https://www.babylonjs-playground.com/#0DE8F4#8
@JS()
class BoneAxesViewer extends AxesViewer {
	
	/// Creates a new BoneAxesViewer
	/// @param scene defines the hosting scene
	/// @param bone defines the target bone
	/// @param mesh defines the target mesh
	/// @param scaleLines defines a scaling factor for line length (1 by default)
	external factory BoneAxesViewer(Scene scene, Bone bone, Mesh mesh, [num? scaleLines]);
	
	/// Gets or sets the target mesh where to display the axes viewer
	external Mesh? get mesh;
	external set mesh(Mesh? value);
	
	/// Gets or sets the target bone where to display the axes viewer
	external Bone? get bone;
	external set bone(Bone? value);
	
	/// Gets current position
	external Vector3 get pos;
	external set pos(Vector3 value);
	
	/// Gets direction of X axis
	external Vector3 get xaxis;
	external set xaxis(Vector3 value);
	
	/// Gets direction of Y axis
	external Vector3 get yaxis;
	external set yaxis(Vector3 value);
	
	/// Gets direction of Z axis
	external Vector3 get zaxis;
	external set zaxis(Vector3 value);
	
	/// Force the viewer to update
	@override
	external void update([Vector3? position, Vector3? xaxis, Vector3? yaxis, Vector3? zaxis]);
	
	/// Releases resources
	@override
	external void dispose();
}

/// Used to show the physics impostor around the specific mesh
@JS()
class PhysicsViewer {
	
	/// Creates a new PhysicsViewer
	/// @param scene defines the hosting scene
	external factory PhysicsViewer(Scene scene);
	
	/// Renders a specified physic impostor
	/// @param impostor defines the impostor to render
	/// @param targetMesh defines the mesh represented by the impostor
	/// @returns the new debug mesh used to render the impostor
	external AbstractMesh? showImpostor(PhysicsImpostor impostor, [Mesh? targetMesh]);
	
	/// Hides a specified physic impostor
	/// @param impostor defines the impostor to hide
	external void hideImpostor(PhysicsImpostor? impostor);
	
	/// Releases all resources
	external void dispose();
}

/// Class used to render a debug view of a given skeleton
/// @see http://www.babylonjs-playground.com/#1BZJVJ#8
@JS()
class SkeletonViewer {
	
	/// Creates a new SkeletonViewer
	/// @param skeleton defines the skeleton to render
	/// @param mesh defines the mesh attached to the skeleton
	/// @param scene defines the hosting scene
	/// @param autoUpdateBonesMatrices defines a boolean indicating if bones matrices must be forced to update before rendering (true by default)
	/// @param renderingGroupId defines the rendering group id to use with the viewer
	external factory SkeletonViewer(Skeleton skeleton, AbstractMesh mesh, Scene scene, [bool? autoUpdateBonesMatrices, num? renderingGroupId]);
	
	/// defines the skeleton to render
	external Skeleton get skeleton;
	external set skeleton(Skeleton value);
	
	/// defines the mesh attached to the skeleton
	external AbstractMesh get mesh;
	external set mesh(AbstractMesh value);
	
	/// defines a boolean indicating if bones matrices must be forced to update before rendering (true by default)
	external bool get autoUpdateBonesMatrices;
	external set autoUpdateBonesMatrices(bool value);
	
	/// defines the rendering group id to use with the viewer
	external num get renderingGroupId;
	external set renderingGroupId(num value);
	
	/// Gets or sets the color used to render the skeleton
	external Color3 get color;
	external set color(Color3 value);
	
	/// Returns the mesh used to render the bones
	external LinesMesh? get debugMesh;
	
	/// Gets or sets a boolean indicating if the viewer is enabled
	external set isEnabled(bool value);
	
	external bool get isEnabled;
	
	/// Update the viewer to sync with current skeleton state
	external void update();
	
	/// Release associated resources
	external void dispose();
}
