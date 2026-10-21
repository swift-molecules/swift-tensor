public import Buffer
import Buffer_Linear
public import Buffer_Linear_Primitive
public import Cardinal
public import Difference
public import Index
public import Memory
public import Memory_Allocator
public import Memory_Allocator_Protocol
public import Ordinal
public import Polarity
public import Storage
public import Tagged

extension Tensor.Value
where
    Element: Copyable & AdditiveArithmetic,
    Layout == Tensor.Layout.Order.Row
{

    @inlinable
    public func adding(
        _ other: borrowing Tensor.Value<Element, Rank, Layout>
    ) throws(Tensor.Broadcast.Error) -> Tensor.Value<Element, Rank, Tensor.Layout.Order.Row> {
        let aligned = try Tensor.Broadcast.align(self._shape, other._shape)
        let count = aligned.count
        var newStorage = Buffer<
            Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>
        >.Linear(
            minimumCapacity: Tagged<Element, Cardinal>(_unchecked: count)
        )

        let lhsStrides = Tensor.Broadcast.strides(of: self._shape, aligned: aligned)
        let rhsStrides = Tensor.Broadcast.strides(of: other._shape, aligned: aligned)
        guard let n = Int(exactly: count.rawValue) else {
            preconditionFailure("Tensor extent exceeds Int.max")
        }
        (0..<n).forEach { i in
            let position = Tensor.Broadcast.position(ofLinearIndex: i, in: aligned)
            let lhsOffset = position.linearize(strides: lhsStrides)
            let rhsOffset = position.linearize(strides: rhsStrides)
            precondition(lhsOffset.polarity != .negative && rhsOffset.polarity != .negative)
            let lhsIdx = Index<Element>(_unchecked: Ordinal(lhsOffset.magnitude.value.rawValue))
            let rhsIdx = Index<Element>(_unchecked: Ordinal(rhsOffset.magnitude.value.rawValue))
            newStorage.append(self._storage[lhsIdx] + other._storage[rhsIdx])
        }
        return Tensor.Value<Element, Rank, Tensor.Layout.Order.Row>(
            shape: aligned,
            strides: Tensor.Strides<Rank>(rowMajor: aligned),
            storage: newStorage
        )
    }

    @inlinable
    public func subtracting(
        _ other: borrowing Tensor.Value<Element, Rank, Layout>
    ) throws(Tensor.Broadcast.Error) -> Tensor.Value<Element, Rank, Tensor.Layout.Order.Row> {
        let aligned = try Tensor.Broadcast.align(self._shape, other._shape)
        let count = aligned.count
        var newStorage = Buffer<
            Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>
        >.Linear(
            minimumCapacity: Tagged<Element, Cardinal>(_unchecked: count)
        )

        let lhsStrides = Tensor.Broadcast.strides(of: self._shape, aligned: aligned)
        let rhsStrides = Tensor.Broadcast.strides(of: other._shape, aligned: aligned)
        guard let n = Int(exactly: count.rawValue) else {
            preconditionFailure("Tensor extent exceeds Int.max")
        }
        (0..<n).forEach { i in
            let position = Tensor.Broadcast.position(ofLinearIndex: i, in: aligned)
            let lhsOffset = position.linearize(strides: lhsStrides)
            let rhsOffset = position.linearize(strides: rhsStrides)
            precondition(lhsOffset.polarity != .negative && rhsOffset.polarity != .negative)
            let lhsIdx = Index<Element>(_unchecked: Ordinal(lhsOffset.magnitude.value.rawValue))
            let rhsIdx = Index<Element>(_unchecked: Ordinal(rhsOffset.magnitude.value.rawValue))
            newStorage.append(self._storage[lhsIdx] - other._storage[rhsIdx])
        }
        return Tensor.Value<Element, Rank, Tensor.Layout.Order.Row>(
            shape: aligned,
            strides: Tensor.Strides<Rank>(rowMajor: aligned),
            storage: newStorage
        )
    }
}

extension Tensor.Value
where
    Element: Copyable & Swift::Numeric,
    Layout == Tensor.Layout.Order.Row
{

    @inlinable
    public func multiplying(
        elementWise other: borrowing Tensor.Value<Element, Rank, Layout>
    ) throws(Tensor.Broadcast.Error) -> Tensor.Value<Element, Rank, Tensor.Layout.Order.Row> {
        let aligned = try Tensor.Broadcast.align(self._shape, other._shape)
        let count = aligned.count
        var newStorage = Buffer<
            Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>
        >.Linear(
            minimumCapacity: Tagged<Element, Cardinal>(_unchecked: count)
        )

        let lhsStrides = Tensor.Broadcast.strides(of: self._shape, aligned: aligned)
        let rhsStrides = Tensor.Broadcast.strides(of: other._shape, aligned: aligned)
        guard let n = Int(exactly: count.rawValue) else {
            preconditionFailure("Tensor extent exceeds Int.max")
        }
        (0..<n).forEach { i in
            let position = Tensor.Broadcast.position(ofLinearIndex: i, in: aligned)
            let lhsOffset = position.linearize(strides: lhsStrides)
            let rhsOffset = position.linearize(strides: rhsStrides)
            precondition(lhsOffset.polarity != .negative && rhsOffset.polarity != .negative)
            let lhsIdx = Index<Element>(_unchecked: Ordinal(lhsOffset.magnitude.value.rawValue))
            let rhsIdx = Index<Element>(_unchecked: Ordinal(rhsOffset.magnitude.value.rawValue))
            newStorage.append(self._storage[lhsIdx] * other._storage[rhsIdx])
        }
        return Tensor.Value<Element, Rank, Tensor.Layout.Order.Row>(
            shape: aligned,
            strides: Tensor.Strides<Rank>(rowMajor: aligned),
            storage: newStorage
        )
    }

    @inlinable
    public func scaled(by scalar: Element) -> Tensor.Value<Element, Rank, Tensor.Layout.Order.Row> {
        let count = self._shape.count
        var newStorage = Buffer<
            Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>
        >.Linear(
            minimumCapacity: Tagged<Element, Cardinal>(_unchecked: count)
        )

        self._storage.forEach { element in
            newStorage.append(element * scalar)
        }
        return Tensor.Value<Element, Rank, Tensor.Layout.Order.Row>(
            shape: self._shape,
            strides: self._strides,
            storage: newStorage
        )
    }
}
