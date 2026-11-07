public import Buffer
import Buffer_Linear
public import Buffer_Linear_Primitive
public import Memory
public import Memory_Allocator
import Memory_Allocator_Protocol
public import Storage

extension Tensor {

    public struct `Value`<Element: ~Copyable, let Rank: Int, Layout: Tensor.Layout.`Protocol`>:
        ~Copyable
    {

        @usableFromInline
        package var _shape: Tensor.Shape<Rank>

        @usableFromInline
        package var _strides: Tensor.Strides<Rank>

        @usableFromInline
        package var _storage:
            Buffer<Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>>
                .Linear

        @inlinable
        public init(
            shape: Tensor.Shape<Rank>,
            strides: Tensor.Strides<Rank>,
            storage:
                consuming Buffer<
                    Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>
                >.Linear
        ) {
            self._shape = shape
            self._strides = strides
            self._storage = storage
        }
    }
}

extension Tensor.Value {

    @inlinable
    public var shape: Tensor.Shape<Rank> {
        _shape
    }

    @inlinable
    public var strides: Tensor.Strides<Rank> {
        _strides
    }
}
