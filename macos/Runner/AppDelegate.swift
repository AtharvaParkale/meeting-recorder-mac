import Cocoa
import FlutterMacOS
import ScreenCaptureKit
import AVFoundation
import CoreMedia

@main
class AppDelegate: FlutterAppDelegate {

  // ===== Existing System Audio =====
  private var stream: SCStream?
  private var audioFile: AVAudioFile?
  private var audioConverter: AVAudioConverter?

  // ===== Added Mic Audio =====
  private var micEngine: AVAudioEngine?
  private var micFile: AVAudioFile?

  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller =
      mainFlutterWindow!.contentViewController as! FlutterViewController

    // ===== System Audio Channel (UNCHANGED) =====
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

    // ===== Mic Audio Channel (ADDED) =====
    let micChannel = FlutterMethodChannel(
      name: "mic_audio",
      binaryMessenger: controller.engine.binaryMessenger
    )

    micChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return }

      switch call.method {
      case "start":
        self.startMicRecording()
        result(nil)

      case "stop":
        self.stopMicRecording(result: result)

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.applicationDidFinishLaunching(notification)
  }

  // MARK: - System Audio Capture (UNCHANGED)

  private func startCapture() {
    NSLog("🎧 Starting system audio capture")

    Task {
      do {
        let content = try await SCShareableContent.current
        guard let display = content.displays.first else {
          NSLog("❌ No display found")
          return
        }

        let config = SCStreamConfiguration()
        config.capturesAudio = true
        config.sampleRate = 44100
        config.channelCount = 2

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

        try stream?.addStreamOutput(
          self,
          type: .audio,
          sampleHandlerQueue: DispatchQueue(label: "audio.queue")
        )

        try await stream?.startCapture()

      } catch {
        NSLog("❌ Failed to start capture: %@", error.localizedDescription)
      }
    }
  }

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

// MARK: - System Audio Stream Output (UNCHANGED)

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

// MARK: - CMSampleBuffer Helper (UNCHANGED)

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

// MARK: - 🎤 Mic Audio (ADDED)

extension AppDelegate {

  func startMicRecording() {
    NSLog("🎤 Starting mic audio recording")

    micEngine = AVAudioEngine()
    let inputNode = micEngine!.inputNode
    let format = inputNode.outputFormat(forBus: 0)

    let outputURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("mic_audio.wav")

    do {
      micFile = try AVAudioFile(
        forWriting: outputURL,
        settings: format.settings
      )

      inputNode.installTap(
        onBus: 0,
        bufferSize: 1024,
        format: format
      ) { [weak self] buffer, _ in
        guard let self = self else { return }
        do {
          try self.micFile?.write(from: buffer)
        } catch {
          NSLog("❌ Mic write error: %@", error.localizedDescription)
        }
      }

      micEngine?.prepare()
      try micEngine?.start()

    } catch {
      NSLog("❌ Failed to start mic recording: %@", error.localizedDescription)
    }
  }

  func stopMicRecording(result: FlutterResult) {
    NSLog("🛑 Stopping mic recording")

    micEngine?.inputNode.removeTap(onBus: 0)
    micEngine?.stop()
    micEngine = nil
    micFile = nil

    let path = FileManager.default.temporaryDirectory
      .appendingPathComponent("mic_audio.wav")
      .path

    NSLog("💾 Mic audio saved at %@", path)
    result(path)
  }
}