local UIUtils = {}


local listTouchEvent = {
    add = function(self, func, atStart)
        if atStart then
            table.insert(self._touchEventListeners, 1, func)
        else
            table.insert(self._touchEventListeners, func)
        end
    end,
    remove = function(self, func)
        for i, v in ipairs(self._touchEventListeners) do
        	if v == func then
                return table.remove(self._touchEventListeners, i)
        	end
        end
    end,
    onEvent = function(self, evt)
        for _, func in ipairs(self._touchEventListeners) do
            if func(self, evt) then return end
        end
    end
}

function UIUtils:changeTouchEventListenerToList(widget)
    if (not widget.addTouchEventListener) or widget.removeTouchEventListener then return end
    
    widget._touchEventListeners = {}
    widget:addTouchEventListener(listTouchEvent.onEvent)
    widget.addTouchEventListener = listTouchEvent.add
    widget.removeTouchEventListener = listTouchEvent.remove
end


local listEvent = {
    add = function(self, func, atStart)
        if atStart then
            table.insert(self._eventListeners, 1, func)
        else
            table.insert(self._eventListeners, func)
        end
    end,
    remove = function(self, func)
        for i, v in ipairs(self._eventListeners) do
            if v == func then
                return table.remove(self._eventListeners, i)
            end
        end
    end,
    onEvent = function(self, evt)
        for _, func in ipairs(self._eventListeners) do
            if func(self, evt) then return end
        end
    end
}

function UIUtils:changeEventListenerToList(widget)
    if (not widget.addEventListener) or widget.removeEventListener then return end

    widget._eventListeners = {}
    widget:addEventListener(listEvent.onEvent)
    widget.addEventListener = listEvent.add
    widget.removeEventListener = listEvent.remove
end

return UIUtils