module atelier.common.array;

import std.parallelism;
import std.range;
import std.typecons;

/// Liste supprimant la fragmentation tout en gardant les index valides.
final class IArray(T, size_t _capacity, bool _useParallelism = false) {
    private size_t _dataTop = 0u;
    private size_t _availableIndexesTop = 0u;
    private size_t _removeTop = 0u;

    private T[_capacity] _dataTable;
    private size_t[_capacity] _availableIndexes;
    private size_t[_capacity] _translationTable;
    private size_t[_capacity] _reverseTranslationTable;
    private size_t[_capacity] _removeTable;

    @property {
        /// Nombre d’éléments contenus
        size_t length() const {
            return _dataTop;
        }

        /// Capacité maximale que peut contenir la liste
        size_t capacity() const {
            return _capacity;
        }

        /// Liste des éléments contenus
        ref T[_capacity] array() {
            return _dataTable;
        }

        /// La liste est-elle vide ?
        bool empty() const {
            return _dataTop == 0;
        }

        /// La liste est-elle pleine ?
        bool full() const {
            return (_dataTop + 1u) == _capacity;
        }
    }

    /// Ajoute un élément à la liste
    size_t push(T value) {
        size_t index;

        if ((_dataTop + 1u) == _capacity) {
            throw new Exception("array overload");
        }

        if (_availableIndexesTop) {
            //Retire le dernier index disponible dans la liste
            _availableIndexesTop--;
            index = _availableIndexes[_availableIndexesTop];
        }
        else {
            //Ou on utilise un nouvel id
            index = _dataTop;
        }

        //Ajoute la valeur à la pile
        _dataTable[_dataTop] = value;
        _translationTable[index] = _dataTop;
        _reverseTranslationTable[_dataTop] = index;

        ++_dataTop;

        return index;
    }

    /// Retire un élément de la liste
    void pop(size_t index) {
        size_t valueIndex = _translationTable[index];

        //Ajoute l’index à la pile des index disponibles
        _availableIndexes[_availableIndexesTop] = index;
        _availableIndexesTop++;

        //Invalide l’index
        _translationTable[index] = -1;

        //Prend la première valeur de la pile et comble le trou
        _dataTop--;
        if (valueIndex < _dataTop) {
            size_t userIndex = _reverseTranslationTable[_dataTop];
            _dataTable[valueIndex] = _dataTable[_dataTop];
            _translationTable[userIndex] = valueIndex;
            _reverseTranslationTable[valueIndex] = userIndex;
        }
    }

    /// Vide la liste
    void clear() {
        _dataTop = 0u;
        _availableIndexesTop = 0u;
        _removeTop = 0u;
    }

    /// Marque un élément à supprimer
    void mark(size_t index) {
        _removeTable[_removeTop] = index;
        _removeTop++;
    }

    /// Supprime tous les éléments marqué pour suppression
    bool sweep() {
        bool hasSwep = _removeTop > 0u;
        for (size_t i = 0u; i < _removeTop; i++) {
            pop(_removeTable[i]);
        }
        _removeTop = 0u;
        return hasSwep;
    }

    static if (_useParallelism) {
        /// Itère sur la liste
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
        /// Ditto
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

    /// Ditto
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
        /// Ditto
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
        /// Ditto
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

    /// Ditto
    int opApply(int delegate(const size_t, const ref T) dlg) const {
        int result;

        foreach (i; 0u .. _dataTop) {
            result = dlg(_reverseTranslationTable[i], _dataTable[i]);

            if (result)
                break;
        }

        return result;
    }

    /// Ditto
    int opApply(int delegate(const Tuple!(const size_t, const T)) dlg) const {
        int result;

        foreach (i; 0u .. _dataTop) {
            result = dlg(tuple!(const size_t, const T)(_reverseTranslationTable[i], _dataTable[i]));

            if (result)
                break;
        }

        return result;
    }

    /// Opérateur ~
    typeof(this) opBinary(string op : "~")(T value) const {
        typeof(this) result = new typeof(this);
        result ~= value;
        return result;
    }

    /// Opérateur ~=
    typeof(this) opOpAssign(string op : "~")(T value) {
        push(value);
        return this;
    }

    /// Accède à un élément
    T opIndex(size_t index) {
        return _dataTable[_translationTable[index]];
    }

    /// Ditto
    T opIndexAssign(T value, size_t index) {
        return _dataTable[_translationTable[index]] = value;
    }

    /// L’index est-il valide ?
    bool has(size_t index) {
        if (index > _dataTop)
            return false;
        if (_translationTable[index] == -1)
            return false;
        return true;
    }

    /// Returne le premier élément dans la liste
    T front() {
        assert(_dataTop > 0);
        return _dataTable[0];
    }

    /// Returne le dernier élément dans la liste
    T back() {
        assert(_dataTop > 0);
        return _dataTable[_dataTop - 1];
    }
}

/// Liste supprimant la fragmentation sans garder les index valides.
final class Array(T, bool _useParallelism = false) {
    private {
        T[] _dataTable;
        size_t[] _removeTable;
    }

    @property {
        /// Nombre d’éléments contenus
        size_t length() const {
            return _dataTable.length;
        }

        /// Capacité maximale que peut contenir la liste
        size_t capacity() const {
            return _dataTable.capacity;
        }

        /// Liste des éléments contenus
        ref T[] array() {
            return _dataTable;
        }

        /// La liste est-elle vide ?
        bool empty() const {
            return _dataTable.length == 0;
        }

        /// La liste est-elle pleine ?
        bool full() const {
            return false;
        }
    }

    /// Ajoute un élément à la liste
    void push(T value) {
        _dataTable ~= value;
    }

    /// Retire un élément de la liste
    void pop(size_t index, bool isStable = false) {
        if (isStable) {
            if (index == 0) {
                _dataTable = _dataTable[1 .. $];
            }
            else if (index + 1 == _dataTable.length) {
                _dataTable.length--;
            }
            else {
                _dataTable = _dataTable[0 .. index] ~ _dataTable[index + 1 .. $];
            }
        }
        else {
            //Prend la première valeur de la pile et comble le trou
            if ((index + 1) < _dataTable.length) {
                _dataTable[index] = _dataTable[$ - 1];
            }

            _dataTable.length--;
        }
    }

    /// Vide la liste
    void clear() {
        _dataTable.length = 0u;
        _removeTable.length = 0u;
    }

    /// Marque un élément à supprimer
    void mark(size_t index) {
        if (!_removeTable.length || index <= _removeTable[$ - 1]) {
            _removeTable ~= index;
            return;
        }

        ptrdiff_t top = (cast(ptrdiff_t) _removeTable.length) - 2;
        while (top > 0) {
            if (index <= _removeTable[top]) {
                if (index < _removeTable[top]) {
                    _removeTable = _removeTable[0 .. top + 1] ~ index ~ _removeTable[top + 1 .. $ -
                        1];
                }
                return;
            }
            top--;
        }

        _removeTable = index ~ _removeTable;
    }

    /// Supprime tous les éléments marqué pour suppression
    bool sweep(bool isStable = false) {
        bool hasSwep = _removeTable.length > 0;
        if (isStable) {
            T[] result;
            for (size_t i; i < _dataTable.length; ++i) {
                if (_removeTable.length && i == _removeTable[$ - 1]) {
                    _removeTable.length--;
                }
                else {
                    result ~= _dataTable[i];
                }
            }
            _dataTable = result;
        }
        else if (_dataTable.length > 0 && _removeTable.length > 0) {
            ptrdiff_t top = (cast(ptrdiff_t) _dataTable.length) - 1;
            foreach (size_t index; _removeTable) {
                //Prend la première valeur de la pile et comble le trou
                if (index < top) {
                    _dataTable[index] = _dataTable[top];
                }
                top--;
            }
            _dataTable.length = top + 1;
        }
        _removeTable.length = 0u;
        return hasSwep;
    }

    static if (_useParallelism) {
        /// Itère sur la liste
        int opApply(int delegate(ref T) dlg) {
            int result;

            foreach (i; parallel(iota(_dataTable.length))) {
                result = dlg(_dataTable[i]);

                if (result)
                    break;
            }

            return result;
        }

        /// Ditto
        int opApplyReverse(int delegate(ref T) dlg) {
            int result;

            foreach_reverse (i; parallel(iota(_dataTable.length))) {
                result = dlg(_dataTable[i]);

                if (result)
                    break;
            }

            return result;
        }
    }
    else {
        /// Ditto
        int opApply(int delegate(ref T) dlg) {
            int result;

            foreach (ref value; _dataTable) {
                result = dlg(value);

                if (result)
                    break;
            }

            return result;
        }

        /// Ditto
        int opApplyReverse(int delegate(ref T) dlg) {
            int result;

            foreach_reverse (ref value; _dataTable) {
                result = dlg(value);

                if (result)
                    break;
            }

            return result;
        }
    }

    /// Ditto
    int opApply(int delegate(const ref T) dlg) const {
        int result;

        foreach (ref value; _dataTable) {
            result = dlg(value);

            if (result)
                break;
        }

        return result;
    }

    /// Ditto
    int opApplyReverse(int delegate(const ref T) dlg) const {
        int result;

        foreach_reverse (ref value; _dataTable) {
            result = dlg(value);

            if (result)
                break;
        }

        return result;
    }

    static if (_useParallelism) {
        /// Ditto
        int opApply(int delegate(const size_t, ref T) dlg) {
            int result;

            foreach (i; parallel(iota(_dataTable.length))) {
                result = dlg(i, _dataTable[i]);

                if (result)
                    break;
            }

            return result;
        }

        /// Ditto
        int opApplyReverse(int delegate(const size_t, ref T) dlg) {
            int result;

            foreach_reverse (i; parallel(iota(_dataTable.length))) {
                result = dlg(i, _dataTable[i]);

                if (result)
                    break;
            }

            return result;
        }
    }
    else {
        /// Ditto
        int opApply(int delegate(const size_t, ref T) dlg) {
            int result;

            foreach (size_t i, ref T value; _dataTable) {
                result = dlg(i, value);

                if (result)
                    break;
            }

            return result;
        }

        /// Ditto
        int opApplyReverse(int delegate(const size_t, ref T) dlg) {
            int result;

            foreach_reverse (size_t i, ref T value; _dataTable) {
                result = dlg(i, value);

                if (result)
                    break;
            }

            return result;
        }
    }

    /// Ditto
    int opApply(int delegate(const size_t, const ref T) dlg) const {
        int result;

        foreach (size_t i, const ref T value; _dataTable) {
            result = dlg(i, value);

            if (result)
                break;
        }

        return result;
    }

    /// Ditto
    int opApplyReverse(int delegate(const size_t, const ref T) dlg) const {
        int result;

        foreach_reverse (size_t i, const ref T value; _dataTable) {
            result = dlg(i, value);

            if (result)
                break;
        }

        return result;
    }

    /// Ditto
    int opApply(int delegate(const Tuple!(const size_t, const T)) dlg) const {
        int result;

        foreach (size_t i, const T value; _dataTable) {
            result = dlg(tuple!(const size_t, const T)(i, value));

            if (result)
                break;
        }

        return result;
    }

    /// Ditto
    int opApplyReverse(int delegate(const Tuple!(const size_t, const T)) dlg) const {
        int result;

        foreach_reverse (size_t i, const T value; _dataTable) {
            result = dlg(tuple!(const size_t, const T)(i, value));

            if (result)
                break;
        }

        return result;
    }

    /// Opérateur ~
    typeof(this) opBinary(string op : "~")(T value) const {
        typeof(this) result = new typeof(this);
        result ~= value;
        return result;
    }

    /// Opérateur ~=
    typeof(this) opOpAssign(string op : "~")(T value) {
        push(value);
        return this;
    }

    /// Accède à un élément
    T opIndex(size_t index) {
        return _dataTable[index];
    }

    /// Ditto
    T opIndexAssign(T value, size_t index) {
        return _dataTable[index] = value;
    }

    /// L’index est-il valide ?
    bool has(size_t index) {
        return index < _dataTable.length;
    }

    /// Returne le premier élément dans la liste
    T front() {
        assert(_dataTable.length > 0);
        return _dataTable[0];
    }

    /// Returne le dernier élément dans la liste
    T back() {
        assert(_dataTable.length > 0);
        return _dataTable[$ - 1];
    }
}
