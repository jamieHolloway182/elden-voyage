StateMachine = Class{}
--state machine constructor
function StateMachine:init(states)
	self.empty = {
		render = function() end,
		update = function() end,
		enter = function() end,
		exit = function() end
	}
	self.states = states or {} -- [name] -> [function that returns states]
	self.current = self.empty
end
--changes current state to new one
function StateMachine:change(stateName, enterParams)
	assert(self.states[stateName]) -- state must exist!
	self.current:exit()
	self.current = self.states[stateName]()
	self.current:enter(enterParams)
end
--updates the current state
function StateMachine:update(dt)
	self.current:update(dt)
end
--renders the current state
function StateMachine:render()
	self.current:render()
end
