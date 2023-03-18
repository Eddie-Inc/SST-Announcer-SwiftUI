//
//  SubjectSuggestion+Load.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 15/2/23.
//

import Foundation
import Vision

let visionQueue = DispatchQueue(label: "com.kaithebuilder.scheduleChopper.vision")

public extension SubjectSuggestion {
    /// Loads the image, populating the ``name`` and ``teacher`` fields.
    /// - Parameter newValue: The new value of the suggestion
    func load(newValue: @escaping (SubjectSuggestion) -> Void) {
        var mutableSelf = self

        textInImage { result in
            defer { newValue(mutableSelf) }

            guard let result, !result.isEmpty else {
                mutableSelf.name = .unidentified
                return
            }

            if result.count == 3 {
                // for subjects with name, location and teacher.
                // location is IGNORED. It might be implemented later. Maybe.
                mutableSelf.name = .some(result[1])
                mutableSelf.teacher = result[2]
            } else if result.count <= 2 {
                // TODO: Use the rectangles for this instead of an arbitrary cutoff
                // for subjects with name, and possibly teacher
                // for subjects that are 2 hours long, sometimes these two are flipped.
                // its just a quirk of the text recognition.

                // if the second result has less than 5 results and the first has more than 5,
                // it is safe to assume that its flipped.
                let flipResults = timeRange.count >= 6 && result[1].count < 5 && result[0].count > 5
                mutableSelf.name = .some(result[flipResults ? 1 : 0])
                if result.count == 2 {
                    mutableSelf.teacher = result[flipResults ? 0 : 1]
                }
            } else {
                mutableSelf.name = .unidentified
                mutableSelf.rawTextContents = result
            }
        }
    }

    /// Like ``load(newValue:)``, but returns the raw results from the `VNRecognizeTextRequest`
    /// instead of a ``SubjectSuggestion``.
    func textInImage(completion: @escaping ([String]?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest { response, error in
            if error != nil {
                completion(nil)
                return
            }

            guard let observations = response.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }

            let recognisedStrings = observations.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }

            completion(recognisedStrings)
        }

        visionQueue.async {
            do {
                try requestHandler.perform([request])
            } catch {}
        }
    }
}
