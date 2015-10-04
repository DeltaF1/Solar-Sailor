    --[[ Copyright 2015 Bruce Hill <bruce@bruce-hill.com>
        This work is free. You can redistribute it and/or modify it under the
        terms of the Do What The Fuck You Want To Public License, Version 2,
        as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.

        Based on: https://elderscrollsonline.reddit.com/comments/2578wc/

        This module has two functions: simulate(colorblindType) and
        daltonize(colorblindType). simulate will simulate the specified type of
        color blindness and daltonize will adjust colors so that someone with the
        specified type of color blindness can more easily differentiate colors.

        simulate() and daltonize() both return a function that toggles their visual
        effect and both should only be called after love.draw() is defined.

        Supported color blindness types: 'protanope', 'deuteranope', 'tritanope' ]]
    local colorblind = {}
    local colorblindTypeCode = {
        protanope = [[
            vec3 lms = vec3(dot(LMS, vec3(0.,2.02344,-2.52581)),
                            dot(LMS, vec3(0.,1.,0.)),
                            dot(LMS, vec3(0.,0.,1.)));]],
        deuteranope = [[
            vec3 lms = vec3(dot(LMS, vec3(1.,0.,0.)),
                            dot(LMS, vec3(.494207,0.,1.24827)),
                            dot(LMS, vec3(0.,0.,1.)));]],
        tritanope = [[
            vec3 lms = vec3(dot(LMS, vec3(1.,0.,0.)),
                            dot(LMS, vec3(0.,1.,0.)),
                            dot(LMS, vec3(-.395913,.801109,0.)));]],
    }
    local sharedCode = [[
    vec3 getError(vec3 color)
    {
        // RGB to LMS matrix conversion
        vec3 LMS = vec3(dot(color, vec3(17.8824,43.5161,4.11935)),
                        dot(color, vec3(3.45565,27.1554,3.86714)),
                        dot(color, vec3(.0299566,.184309,1.46709)));
       
        %s
        vec3 error = vec3(
            dot(lms, vec3(.0809444479,-.130504409,.116721066)),
            dot(lms, vec3(-.0102485335,.0540193266,-.113614708)),
            dot(lms, vec3(-.000365296938,-.00412161469,.693511405)));
        return error;
    }
    ]]

    local function configure(shaderCode, colorblindType)
        assert(colorblindTypeCode[colorblindType], 'Color blindness type must be "protanope", "deuteranope", or "tritanope"')
        assert(love.draw, "love.draw hasn't been defined yet!")
        local oldDraw = love.draw
        local canvas = love.graphics.newCanvas()
        local shader = love.graphics.newShader(shaderCode:format(colorblindTypeCode[colorblindType]))
        function love.draw(...)
            local oldCanvas = love.graphics.getCanvas()
            love.graphics.setCanvas(canvas)
            canvas:clear(love.graphics.getBackgroundColor())
            oldDraw(...)
            love.graphics.setCanvas(oldCanvas)
            local oldShader = love.graphics.getShader()
            love.graphics.setShader(shader)
            love.graphics.draw(canvas)
            love.graphics.setShader(oldShader)
        end
        return function() love.draw, oldDraw = oldDraw, love.draw end
    end

    local simulateShaderCode = sharedCode..[[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
    {
        vec4 original = Texel(texture, texture_coords);
        original.rgb = getError(original.rgb);
        return clamp(original, 0., 1.);
    }
    ]]
    function colorblind.simulate(colorblindType)
        return configure(simulateShaderCode, colorblindType)
    end

    local daltonizeShaderCode = sharedCode..[[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
    {
        vec4 original = Texel(texture, texture_coords);
        vec3 error = getError(original.rgb);
        error = (original.rgb - error);
       
        // Shift colors towards visible spectrum (apply error modifications)
        vec3 correction = vec3(0., error.r * 0.7 + error.g * 1.0, error.r * 0.7 + error.b * 1.0);
       
        // Add compensation to original values
        original.rgb += correction;
        return clamp(original, 0., 1.);
    }
    ]]
    function colorblind.daltonize(colorblindType)
        return configure(daltonizeShaderCode, colorblindType)
    end

    return colorblind