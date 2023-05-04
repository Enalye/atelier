/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.common.array;

import std.parallelism;
import std.range;
import std.typecons;

/**
	Special Array that remove fragmentation while keeping indexes valid.
*/
class Array(T, size_t _capacity, bool _useParallelism = false) {
    private size_t _dataTop = 0u;
    private size_t _availableIndexesTop = 0u;
    private size_t _removeTop = 0u;

    private T[_capacity] _dataTable;
    private size_t[_capacity] _availableIndexes;
    private size_t[_capacity] _translationTable;
    private size_t[_capacity] _reverseTranslationTable;
    private size_t[_capacity] _removeTable;

    @property {
        size_t length() const {
            return _dataTop;
        }

        size_t capacity() const {
            return _capacity;
        }

        ref T[_capacity] data() {
            return _dataTable;
        }

        bool empty() const {
            return _dataTop == 0;
        }

        bool full() const {
            return (_dataTop + 1u) == _capacity;
        }
    }

    size_t push(T value) {
        size_t index;

        if ((_dataTop + 1u) == _capacity) {
            throw new Exception("Array overload");
        }

        if (_availableIndexesTop) {
            //Take out the last available index on the list.
            _availableIndexesTop--;
            index = _availableIndexes[_availableIndexesTop];
        }
        else {
            //Or use a new id.
            index = _dataTop;
        }

        //Add the value to the data stack.
        _dataTable[_dataTop] = value;
        _translationTable[index] = _dataTop;
        _reverseTranslationTable[_dataTop] = index;

        ++_dataTop;

        return index;
    }

    void pop(size_t index) {
        size_t valueIndex = _translationTable[index];

        //Push the index on the available indexes stack.
        _availableIndexes[_availableIndexesTop] = index;
        _availableIndexesTop++;

        //Invalidate the index.
        _translationTable[index] = -1;

        //Take the top value on the stack and fill the gap.
        _dataTop--;
        if (valueIndex < _dataTop) {
            size_t userIndex = _reverseTranslationTable[_dataTop];
            _dataTable[valueIndex] = _dataTable[_dataTop];
            _translationTable[userIndex] = valueIndex;
            _reverseTranslationTable[valueIndex] = userIndex;
        }
    }

    void reset() {
        _dataTop = 0u;
        _availableIndexesTop = 0u;
        _removeTop = 0u;
    }

    void mark(size_t index) {
        _removeTable[_removeTop] = index;
        _removeTop++;
    }

    void sweep() {
        for (size_t i = 0u; i < _removeTop; i++) {
            pop(_removeTable[i]);
        }
        _removeTop = 0u;
    }

    static if (_useParallelism) {
        int opApply(int delegate(ref T) dlg) {
            int result;

            foreach (i; parallel(iota(_dataTop))) {
                result = dlg(_dataTable[i]);

                if (result)
                    break;
            }

            return result;
        }
    }
    else {
        int opApply(int delegate(ref T) dlg) {
            int result;

            foreach (i; 0u .. _dataTop) {
                result = dlg(_dataTable[i]);

                if (result)
                    break;
            }

            return result;
        }
    }

    int opApply(int delegate(const ref T) dlg) const {
        int result;

        foreach (i; 0u .. _dataTop) {
            result = dlg(_dataTable[i]);

            if (result)
                break;
        }

        return result;
    }

    static if (_useParallelism) {
        int opApply(int delegate(const size_t, ref T) dlg) {
            int result;

            foreach (i; parallel(iota(_dataTop))) {
                result = dlg(_reverseTranslationTable[i], _dataTable[i]);

                if (result)
                    break;
            }

            return result;
        }
    }
    else {
        int opApply(int delegate(const size_t, ref T) dlg) {
            int result;

            foreach (i; 0u .. _dataTop) {
                result = dlg(_reverseTranslationTable[i], _dataTable[i]);

                if (result)
                    break;
            }

            return result;
        }
    }

    int opApply(int delegate(const size_t, const ref T) dlg) const {
        int result;

        foreach (i; 0u .. _dataTop) {
            result = dlg(_reverseTranslationTable[i], _dataTable[i]);

            if (result)
                break;
        }

        return result;
    }

    int opApply(int delegate(const Tuple!(const size_t, const T)) dlg) const {
        int result;

        foreach (i; 0u .. _dataTop) {
            result = dlg(tuple!(const size_t, const T)(_reverseTranslationTable[i], _dataTable[i]));

            if (result)
                break;
        }

        return result;
    }

    T opIndex(size_t index) {
        return _dataTable[_translationTable[index]];
    }

    T opIndexAssign(T value, size_t index) {
        return _dataTable[_translationTable[index]] = value;
    }

    bool has(size_t index) {
        if (index > _dataTop)
            return false;
        if (_translationTable[index] == -1)
            return false;
        return true;
    }

    /// Returns the first element in the list
    T front() {
        assert(_dataTop > 0);
        return _dataTable[0];
    }

    /// Returns the last element in the list
    T back() {
        assert(_dataTop > 0);
        return _dataTable[_dataTop - 1];
    }
}
