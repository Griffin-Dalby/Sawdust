--[[

    Tween Information Translator

    Griffin Dalby
    2025.08.22

    Translates roblox TweenInfos or convertable tables into a wrapped
    instance

--]]

local info_translator = {}
info_translator.__index = info_translator

export type StringEasingStyles = 'Linear'|'Sine'|'Quad'|'Cubic'|'Quart'|'Quint'|'Exponential'|'Circular'|'Back'|'Bounce'|'Elastic'
export type StringEasingDirections = 'In'|'Out' |'InOut'

export type TweenData = {
    time: number?,
    easingStyle: Enum.EasingStyle? | StringEasingStyles?,
    easingDirection: Enum.EasingDirection? | StringEasingDirections?,
    repeatCount: number?,
    reverses: boolean?,
    delayTime: number?
}

type self = {}
export type STweenInfo = typeof(setmetatable({} :: self, info_translator))

--[[ info_translator.new()
    Deconstructs the passed tween data & wraps it. ]]
function info_translator.new(tweenData: TweenInfo|TweenData) : STweenInfo
    local self = setmetatable({} :: self, info_translator)

    --> Parse Table
    local isTable = type(tweenData) == 'table'
    if isTable then
        if tweenData.easingStyle and type(tweenData.easingStyle)=='string' then
            local styleEnum = Enum.EasingStyle[tweenData.easingStyle]
            assert(styleEnum, `Failed to find Style Enum for "{tweenData.easingStyle}!"`)

            tweenData.easingStyle = styleEnum; end
        if tweenData.easingDirection and type(tweenData.easingDirection)=='string' then
            local dirEnum = Enum.EasingDirection[tweenData.easingDirection]
            assert(dirEnum, `Failed to find Direction Enum for "{tweenData.easingDirection}"!`)

            tweenData.easingDirection = dirEnum; end
    end

    --> Construct self
    self.raw_info = table.clone(tweenData)

    self.info = TweenInfo.new(
        tweenData.time or 1,
        tweenData.easingStyle or Enum.EasingStyle.Quad,
        tweenData.easingDirection or Enum.EasingDirection.Out,
        tweenData.repeatCount or 0,
        tweenData.reverses or false,
        tweenData.delayTime or 0
    )

    return self
end

return info_translator