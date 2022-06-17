function math.randomFloat(min, max, precision)
    if not max or not min then
        return 0
    end
    if max < min then
        local temp = max
        max = min
        min = temp
    end
    local range = max - min
    local offset = range * math.random()
    local unrounded = min + offset

    if not precision then
        return unrounded
    end

    local powerOfTen = 10 ^ precision
    return math.floor(unrounded * powerOfTen + 0.5) / powerOfTen
end