// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

type ptr is uint64;

struct Node {
    ptr value;
    ptr next;
    ptr prev;
}

struct DLL {
    uint64 counter;
    uint64 length;
    ptr head;
    ptr tail;
    mapping(ptr => Node) nodes;
}

ptr constant NULL_PTR = ptr.wrap(0);

error InvalidPointer();
error InvalidLength();
error ListEmpty();

function createPointer(uint64 _seed) pure returns (ptr) {
    return ptr.wrap(_seed);
}

function isValidPointer(ptr _ptr) pure returns (bool) {
    return ptr.unwrap(_ptr) != ptr.unwrap(NULL_PTR);
}

function validatePointer(ptr _ptr) pure {
    if (!isValidPointer(_ptr)) revert InvalidPointer();
}

library NodeLib {
    function isValidNode(Node storage _node) internal view returns (bool) {
        return isValidPointer(_node.value);
    }

    function validateNode(Node storage _node) internal view {
        if (!isValidNode(_node)) revert InvalidPointer();
    }

    function set(Node storage _node, ptr _value, ptr _next, ptr _prev) internal {
        _node.value = _value;
        _node.next = _next;
        _node.prev = _prev;
    }

    function clear(Node storage _node) internal {
        _node.value = NULL_PTR;
        _node.next = NULL_PTR;
        _node.prev = NULL_PTR;
    }
}

library DoublyLinkedListLib {
    using NodeLib for Node;

    function valueAt(DLL storage _dll, ptr _node) internal view returns (ptr node) {
        node = _dll.nodes[_node].value;
    }

    function at(DLL storage _dll, uint64 i) internal view returns (ptr node) {
        uint64 length = _dll.length;
        if (i >= length) revert InvalidLength();
        if (i < length / 2) {
            node = _dll.head;
            while (i != 0) {
                node = _dll.nodes[node].next;
                --i;
            }
        } else {
            node = _dll.tail;
            while (i != length - 1) {
                node = _dll.nodes[node].prev;
                ++i;
            }
        }
    }

    function clear(DLL storage _dll) internal {
        _dll.head = _dll.tail = NULL_PTR;
        _dll.length = 0;
    }

    function find(
        DLL storage _dll,
        function(ptr, uint64, bytes memory) view returns (bool) _isMatch,
        bytes memory _data
    ) internal view returns (ptr node, uint64 i) {
        node = _dll.head;
        while (isValidPointer(node)) {
            if (_isMatch(node, i, _data)) return (node, i);
            node = _dll.nodes[node].next;
            ++i;
        }
        return (NULL_PTR, ~uint64(0));
    }

    function rfind(
        DLL storage _dll,
        function(ptr, uint64, bytes memory) view returns (bool) _isMatch,
        bytes memory _data
    ) internal view returns (ptr node, uint64 i) {
        node = _dll.tail;
        i = _dll.length;
        while (isValidPointer(node)) {
            if (_isMatch(node, i, _data)) return (node, i);
            node = _dll.nodes[node].prev;
            --i;
        }
        return (NULL_PTR, ~uint64(0));
    }

    function each(DLL storage _dll, function(ptr, uint64, bytes memory) returns (bool) _onEach, bytes memory _data)
        internal
    {
        uint64 i;
        ptr node = _dll.head;
        while (isValidPointer(node)) {
            if (!_onEach(node, i, _data)) break;
            node = _dll.nodes[node].next;
            ++i;
        }
    }

    function push(DLL storage _dll, ptr _value) internal {
        insertBefore(_dll, NULL_PTR, _value);
    }

    function pop(DLL storage _dll) internal {
        remove(_dll, _dll.tail);
    }

    function remove(DLL storage _dll, ptr _node) internal {
        validatePointer(_node);
        _dll.nodes[_node].validateNode();

        ptr next = _dll.nodes[_node].next;
        ptr prev = _dll.nodes[_node].prev;

        if (isValidPointer(prev)) {
            ptr prevValue = _dll.nodes[prev].value;
            ptr prevPrev = _dll.nodes[prev].prev;
            _dll.nodes[prev].set(prevValue, next, prevPrev);
        } else {
            _dll.head = next;
        }

        if (isValidPointer(next)) {
            ptr nextValue = _dll.nodes[next].value;
            ptr nextNext = _dll.nodes[next].next;
            _dll.nodes[next].set(nextValue, nextNext, prev);
        } else {
            _dll.tail = prev;
        }

        --_dll.length;
        _dll.nodes[_node].clear();
    }

    /// To insert to the end, pass `NULL_PTR` as `_before`.
    function insertBefore(DLL storage _dll, ptr _before, ptr _value) internal {
        validatePointer(_value);
        ptr node;
        ptr prev;

        if (isValidPointer(_before)) {
            ptr beforeValue = _dll.nodes[_before].value;
            ptr beforeNext = _dll.nodes[_before].next;
            prev = _dll.nodes[_before].prev;
            node = _createNode(_dll, _value, _before, prev);
            _dll.nodes[_before].set(beforeValue, beforeNext, node);
        } else {
            prev = _dll.tail;
            _dll.tail = node = _createNode(_dll, _value, NULL_PTR, prev);
        }

        if (isValidPointer(prev)) {
            ptr prevValue = _dll.nodes[prev].value;
            ptr prevPrev = _dll.nodes[prev].prev;
            _dll.nodes[prev].set(prevValue, node, prevPrev);
        } else {
            _dll.head = node;
        }

        ++_dll.length;
    }

    function update(DLL storage _dll, ptr _node, ptr _value) internal {
        validatePointer(_node);
        validatePointer(_value);
        _dll.nodes[_node].validateNode();

        ptr next = _dll.nodes[_node].next;
        ptr prev = _dll.nodes[_node].prev;
        _dll.nodes[_node].set(_value, next, prev);
    }

    /// HELPERS ///

    function _createPointer(DLL storage _dll) private returns (ptr) {
        return createPointer(++_dll.counter);
    }

    function _createNode(DLL storage _dll, ptr _value, ptr _next, ptr _prev) private returns (ptr) {
        ptr newNodePtr = _createPointer(_dll);
        _dll.nodes[newNodePtr].set(_value, _next, _prev);
        return newNodePtr;
    }
}
