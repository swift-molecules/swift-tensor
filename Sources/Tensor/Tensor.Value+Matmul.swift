public import Buffer_Linear_Primitive
public import Memory_Allocator_Protocol
public import Tagged
public import Buffer_Linear
public import Memory_Allocator
public import Storage
public import Difference

public import Index

public import Cardinal
public import Ordinal
public import Buffer
public import Storage_Memory
public import Memory

extension Tensor.Value
where
    Element: Copyable & Swift.Numeric,
    Layout == Tensor.Layout.Order.Row,
    Rank == 2
{

    @inlinable
    public func multiplied(
        by other: borrowing Tensor.Value<Element, 2, Layout>
    ) throws(Tensor.Broadcast.Error) -> Tensor.Value<Element, 2, Tensor.Layout.Order.Row> {
        let m = self._shape.dims[0]
        let p = self._shape.dims[1]
        let pOther = other._shape.dims[0]
        let n = other._shape.dims[1]
        if p != pOther {
            throw .incompatibleShapes(axis: .one, lhs: p, rhs: pOther)
        }

        var resultDims = InlineArray<2, Cardinal>(repeating: .zero)
        resultDims[0] = m
        resultDims[1] = n
        let resultShape = Tensor.Shape<2>(resultDims)
        let total = resultShape.count

        var storage = Buffer<
            Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>
        >.Linear(
            minimumCapacity: Tagged<Element, Cardinal>(_unchecked: total)
        )

        let mInt = Int(exactly: m.rawValue)!
        let pInt = Int(exactly: p.rawValue)!
        let nInt = Int(exactly: n.rawValue)!
        let aRowStride = try! self._strides.values[0].intValue()
        let aColStride = try! self._strides.values[1].intValue()
        let bRowStride = try! other._strides.values[0].intValue()
        let bColStride = try! other._strides.values[1].intValue()

        (0..<mInt).forEach { i in
            (0..<nInt).forEach { k in
                var accumulator = Element.zero
                (0..<pInt).forEach { j in

                    let aOffset = i * aRowStride + j * aColStride
                    let bOffset = j * bRowStride + k * bColStride
                    precondition(aOffset >= 0 && bOffset >= 0)
                    let aIdx = Index<Element>(_unchecked: Ordinal(UInt(aOffset)))
                    let bIdx = Index<Element>(_unchecked: Ordinal(UInt(bOffset)))
                    accumulator += self._storage[aIdx] * other._storage[bIdx]
                }
                storage.append(accumulator)
            }
        }

        return Tensor.Value<Element, 2, Tensor.Layout.Order.Row>(
            shape: resultShape,
            strides: Tensor.Strides<2>(rowMajor: resultShape),
            storage: storage
        )
    }
}
