//
//  ScheduleQRView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 8/3/23.
//

import SwiftUI
import Chopper

struct ScheduleQRView: View {
    @State var image: UIImage

    init() {
        let manager = ScheduleManager.default
        let schedule = manager.schedule
        guard let data = try? JSONEncoder().encode(schedule),
              let compressed = try? (data as NSData).compressed(using: .lzfse) else {
            fatalError("Could not get schedule data")
        }
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            fatalError("QR Filter not found")
        }
        qrFilter.setValue(compressed, forKey: "inputMessage")
        guard let qrImage = qrFilter.outputImage else {
            fatalError("Could not generate QR image")
        }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        print("Compressed data: \(compressed.description)")
        print("QR image created: \(qrImage.description)")

        let context = CIContext()
        // attempt to get a CGImage from our CIImage
        guard let cgimg = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) else {
            fatalError("Failed to turn QR image (CIImage) into CGImage")
        }
        // convert that to a UIImage
        self.image = UIImage(cgImage: cgimg)
    }

    var body: some View {
        List {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        }
    }
}

struct ScheduleQRView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleQRView()
    }
}
