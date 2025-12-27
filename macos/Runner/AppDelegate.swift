import Cocoa
import FlutterMacOS
import ScreenCaptureKit
import AVFoundation
import CoreMedia

@main
class AppDelegate: FlutterAppDelegate {

  // MARK: - Properties

  private var stream: SCStream?
  private var audioFile: AVAudioFile?
  private var audioConverter: AVAudioConverter?

  // MARK: - App Lifecycle

  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller =
      mainFlutterWindow!.contentViewController as! FlutterViewController

    let channel = FlutterMethodChannel(
      name: "system_audio",
      binaryMessenger: controller.engine.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return }

      switch call.method {
      case "start":
        self.startCapture()
        result(nil)

      case "stop":
        self.stopCapture(result: result)

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  // MARK: - Start System Audio Capture

  private func startCapture() {
    NSLog("🎧 Starting system audio capture")

    Task {
      do {
        let content = try await SCShareableContent.current
        guard let display = content.displays.first else {
          NSLog("❌ No display found")
          return
        }

        // Stream configuration (audio only)
        let config = SCStreamConfiguration()
        config.capturesAudio = true
        config.sampleRate = 44100
        config.channelCount = 2

        // Output file
        let outputURL = FileManager.default.temporaryDirectory
          .appendingPathComponent("system_audio.wav")

        let outputFormat = AVAudioFormat(
          commonFormat: .pcmFormatFloat32,
          sampleRate: 44100,
          channels: 2,
          interleaved: false
        )!

        audioFile = try AVAudioFile(
          forWriting: outputURL,
          settings: outputFormat.settings
        )

        let filter = SCContentFilter(
          display: display,
          excludingWindows: []
        )

        stream = SCStream(
          filter: filter,
          configuration: config,
          delegate: nil
        )

        // addStreamOutput → throws, NOT async
        try stream?.addStreamOutput(
          self,
          type: .audio,
          sampleHandlerQueue: DispatchQueue(label: "audio.queue")
        )

        try await stream?.startCapture()
        NSLog("✅ System audio capture started")

      } catch {
        NSLog("❌ Failed to start capture: %@", error.localizedDescription)
      }
    }
  }

  // MARK: - Stop Capture

  private func stopCapture(result: @escaping FlutterResult) {
    NSLog("⏹ Stopping capture")

    Task {
      do {
        try await stream?.stopCapture()
        stream = nil
        audioConverter = nil

        let path = FileManager.default.temporaryDirectory
          .appendingPathComponent("system_audio.wav")
          .path

        NSLog("💾 Audio saved at %@", path)
        result(path)

      } catch {
        NSLog("❌ Failed to stop capture: %@", error.localizedDescription)
        result(nil)
      }
    }
  }
}

// MARK: - SCStreamOutput (Audio Handling)

extension AppDelegate: SCStreamOutput {

  func stream(
    _ stream: SCStream,
    didOutputSampleBuffer sampleBuffer: CMSampleBuffer,
    of type: SCStreamOutputType
  ) {
    guard type == .audio,
          let file = audioFile,
          let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer),
          let asbdPtr = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc)
    else { return }

    var asbd = asbdPtr.pointee

    let inputFormat = AVAudioFormat(
      streamDescription: &asbd
    )!

    // Lazily create converter
    if audioConverter == nil {
      audioConverter = AVAudioConverter(
        from: inputFormat,
        to: file.processingFormat
      )
    }

    guard let converter = audioConverter,
          let pcmBuffer = sampleBuffer.toPCMBuffer(format: inputFormat)
    else { return }

    let convertedBuffer = AVAudioPCMBuffer(
      pcmFormat: file.processingFormat,
      frameCapacity: pcmBuffer.frameCapacity
    )!

    let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
      outStatus.pointee = .haveData
      return pcmBuffer
    }

    converter.convert(
      to: convertedBuffer,
      error: nil,
      withInputFrom: inputBlock
    )

    do {
      try file.write(from: convertedBuffer)
    } catch {
      NSLog("❌ Failed to write audio: %@", error.localizedDescription)
    }
  }
}

// MARK: - CMSampleBuffer → AVAudioPCMBuffer

extension CMSampleBuffer {

  func toPCMBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {
    guard let blockBuffer = CMSampleBufferGetDataBuffer(self) else { return nil }

    let length = CMBlockBufferGetDataLength(blockBuffer)
    let bytesPerFrame =
      format.streamDescription.pointee.mBytesPerFrame

    let frameCount = AVAudioFrameCount(length / Int(bytesPerFrame))

    guard let buffer = AVAudioPCMBuffer(
      pcmFormat: format,
      frameCapacity: frameCount
    ) else { return nil }

    buffer.frameLength = frameCount

    CMBlockBufferCopyDataBytes(
      blockBuffer,
      atOffset: 0,
      dataLength: length,
      destination: buffer.floatChannelData![0]
    )

    return buffer
  }
}