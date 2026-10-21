public import Buffer_Linear_Primitive
public import Cardinal
public import Difference
public import Index
public import Ordinal
public import Polarity
public import Storage
public import Tagged

extension Tensor.Value where Element: Copyable {

    @inlinable
    public func element(
        at position: Tensor.Index.Position<Rank>
    ) throws(Tensor.Index.Error) -> Element {
        try position.validate(against: _shape)
        let offset = position.linearize(strides: _strides)

        precondition(offset.polarity != .negative, "Tensor linear offset must be nonnegative")
        let flatIndex = Index<Element>(_unchecked: Ordinal(offset.magnitude.value.rawValue))
        return _storage[flatIndex]
    }
}
