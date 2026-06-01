//
//  Reward3DView.swift
//  XJournal AI
//
//  Premium spinnable, light-catching 3D reward object — proves the "tilt to catch the light"
//  achievement experience. Procedural metallic geometry, so it needs NO 3D asset or GPU model
//  at runtime. To use a custom object later (e.g. exported from SAM 3D → .usdz), drop the .usdz
//  in the bundle and load it via `SCNScene(named:)` in place of `makeObject()`.
//
//  Auto-rotates; on a real device, tilt sweeps the key light across the metal (CoreMotion).
//  In the Simulator (no motion sensors) it still spins and you can drag to orbit.
//

import SwiftUI
import SceneKit
import CoreMotion

struct Reward3DView: UIViewRepresentable {
    /// Metal tint — gold by default; pass a different color per reward tier (silver/bronze/etc.).
    var tint: UIColor = UIColor(red: 0.86, green: 0.70, blue: 0.26, alpha: 1.0)

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.antialiasingMode = .multisampling4X
        view.autoenablesDefaultLighting = false
        view.allowsCameraControl = true            // drag to orbit (works in the Simulator)
        view.scene = Self.makeScene(tint: tint)
        context.coordinator.attach(view)
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator() }
    static func dismantleUIView(_ uiView: SCNView, coordinator: Coordinator) { coordinator.stop() }

    // MARK: - Scene

    private static func makeScene(tint: UIColor) -> SCNScene {
        let scene = SCNScene()
        // Soft uniform environment so the metal reads as gold (PBR needs something to reflect).
        scene.lightingEnvironment.contents = UIColor(white: 0.82, alpha: 1.0)
        scene.lightingEnvironment.intensity = 1.1

        let metal = SCNMaterial()
        metal.lightingModel = .physicallyBased
        metal.diffuse.contents = tint
        metal.metalness.contents = 1.0
        metal.roughness.contents = 0.18

        // A faceted medallion: a torus ring around a core sphere (reads as a premium emblem).
        let ring = SCNNode(geometry: SCNTorus(ringRadius: 1.05, pipeRadius: 0.34))
        ring.geometry?.materials = [metal]
        ring.name = "reward"
        let core = SCNNode(geometry: SCNSphere(radius: 0.62))
        core.geometry?.materials = [metal]
        ring.addChildNode(core)
        ring.eulerAngles = SCNVector3(Float.pi / 7, 0, 0)        // slight tilt to show depth
        ring.runAction(.repeatForever(.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 9)))
        scene.rootNode.addChildNode(ring)

        let key = SCNNode()
        key.name = "keyLight"
        key.light = SCNLight()
        key.light?.type = .omni
        key.light?.intensity = 1300
        key.position = SCNVector3(3, 4, 6)
        scene.rootNode.addChildNode(key)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 280
        scene.rootNode.addChildNode(ambient)

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(0, 0, 5.2)
        scene.rootNode.addChildNode(camera)

        return scene
    }

    // MARK: - Tilt (catch the light)

    final class Coordinator {
        private let motion = CMMotionManager()
        private weak var view: SCNView?

        func attach(_ view: SCNView) {
            self.view = view
            guard motion.isDeviceMotionAvailable else { return }   // Simulator: spin/drag only
            motion.deviceMotionUpdateInterval = 1.0 / 30.0
            motion.startDeviceMotionUpdates(to: .main) { [weak self] m, _ in
                guard let m = m,
                      let light = self?.view?.scene?.rootNode.childNode(withName: "keyLight", recursively: false)
                else { return }
                // Tilt slides the key light so the highlight sweeps across the metal.
                light.position = SCNVector3(Float(m.attitude.roll) * 6.0,
                                            4.0 + Float(m.attitude.pitch) * 4.0,
                                            6.0)
            }
        }
        func stop() { motion.stopDeviceMotionUpdates() }
    }
}

/// A complete reward "moment" using the 3D object — matches the FIRST GEAR achievement layout
/// (dark showcase, tier chip, XP). Drop this into the achievement flow or present it on a milestone.
struct RewardShowcaseView: View {
    var title: String = "FIRST GEAR"
    var subtitle: String = "Complete your first training module"
    var tier: String = "BRONZE"
    var xp: Int = 100
    var tint: UIColor = UIColor(red: 0.80, green: 0.52, blue: 0.26, alpha: 1.0)   // bronze

    var body: some View {
        VStack(spacing: 18) {
            Reward3DView(tint: tint)
                .frame(height: 260)
            Text(title).font(.largeTitle.weight(.heavy))
            Text(tier)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 14).padding(.vertical, 6)
                .background(Capsule().fill(Color(tint)))
                .foregroundStyle(.white)
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            Text("\(xp) XP")
                .font(.callout.weight(.bold))
                .padding(.horizontal, 16).padding(.vertical, 6)
                .background(Capsule().fill(.yellow.opacity(0.9)))
                .foregroundStyle(.black)
            Text("Tilt your phone to catch the light ✨")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RadialGradient(colors: [Color(white: 0.16), .black],
                           center: .center, startRadius: 40, endRadius: 420)
            .ignoresSafeArea()
        )
    }
}

#Preview { RewardShowcaseView() }
