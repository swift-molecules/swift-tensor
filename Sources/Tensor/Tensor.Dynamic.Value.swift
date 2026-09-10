public import Buffer_Linear_Primitive
public import Memory_Allocator_Protocol
public import Buffer_Linear
public import Memory_Allocator
public import Storage

public import Buffer

public import Memory
public import Storage_Memory

extension Tensor.Dynamic {

    public struct `Value`<Element: ~Copyable>: ~Copyable {

        @usableFromInline
        package var _shape: Tensor.Dynamic.Shape

        @usableFromInline
        package var _storage:
            Buffer<Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>>
                .Linear

        @inlinable
        public init(
            shape: Tensor.Dynamic.Shape,
            storage:
                consuming Buffer<
                    Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>
                >.Linear
        ) {
            self._shape = shape
            self._storage = storage
        }
    }
}
