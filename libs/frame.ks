// change frame from ship to new frame but keep vector pointing to the same direction
// to change back to ship frame, use change_frame(-frame, vec) or rotate_frame(frame, vec)
global function change_frame {
    parameter frame, _vec.
    return _vec * frame:inverse.
}

// change frame and rotate vector from ship to new frame
// to rotate back to ship frame, use rotate_frame(-frame, vec) or change_frame(frame, vec)
global function rotate_frame {
    parameter frame, _vec.
    return _vec * frame.
}

// name_center_frame