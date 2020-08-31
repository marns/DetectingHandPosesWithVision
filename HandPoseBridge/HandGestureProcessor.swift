/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This class is a state machine that transitions between states based on pair
    of points stream. These points are the tips for thumb and index finger.
    If the tips are closer than the desired distance, the state is "pinched", otherwise it's "apart".
    There are also "possiblePinch" and "possibeApart" states that are used to smooth out state transitions.
    During these possible states HandGestureProcessor collects the required amount of evidence before committing to a definite state.
*/

import CoreGraphics

@objc public class HandGestureProcessor : NSObject {
    public enum State {
        case possiblePinch
        case pinched
        case possibleApart
        case apart
        case unknown
    }
    
    //public typealias PointsPair = (thumbTip: CGPoint, indexTip: CGPoint)
    
    private var state = State.unknown {
        didSet {
            didChangeStateClosure?(state)
        }
    }
    
    @objc public static let shared = HandGestureProcessor()
    
    private var pinchEvidenceCounter = 0
    private var apartEvidenceCounter = 0
    private let pinchMaxDistance: CGFloat
    private let evidenceCounterStateTrigger: Int
    
    public var didChangeStateClosure: ((State) -> Void)?
    public private (set) var lastProcessedPointsPair = PointsPair.zero
    
    public init(pinchMaxDistance: CGFloat = 40, evidenceCounterStateTrigger: Int = 3) {
        self.pinchMaxDistance = pinchMaxDistance
        self.evidenceCounterStateTrigger = evidenceCounterStateTrigger
    }
    
    @objc public func reset() {
        state = .unknown
        pinchEvidenceCounter = 0
        apartEvidenceCounter = 0
    }
    
    //@objc public func processPointsPair(_ pointsPair: PointsPair) {
    @objc public func processPointsPair(thumbTip: CGPoint, indexTip: CGPoint) {
        lastProcessedPointsPair = PointsPair(thumbTip: thumbTip, indexTip: indexTip)
        let distance = indexTip.distance(from: thumbTip)
        if distance < pinchMaxDistance {
            // Keep accumulating evidence for pinch state.
            pinchEvidenceCounter += 1
            apartEvidenceCounter = 0
            // Set new state based on evidence amount.
            state = (pinchEvidenceCounter >= evidenceCounterStateTrigger) ? .pinched : .possiblePinch
        } else {
            // Keep accumulating evidence for apart state.
            apartEvidenceCounter += 1
            pinchEvidenceCounter = 0
            // Set new state based on evidence amount.
            state = (apartEvidenceCounter >= evidenceCounterStateTrigger) ? .apart : .possibleApart
        }
    }
}

// MARK: - CGPoint helpers

extension CGPoint {

    public static func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
    
    public func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
}

