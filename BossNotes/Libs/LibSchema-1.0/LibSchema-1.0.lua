--[[

$Revision: 9 $

(C) Copyright 2009,2010 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Documentation

--- **LibSchema-1.0** allows you to define schemas for (complex) Lua types and
-- then validate Lua values against those schemas. A typical use of
-- LibSchema-1.0 is the validation of values received via AceSerializer-3.0
-- and AceComm-3.0 from other game clients. Of course, the library can also be
-- used for other validation tasks.
-- @class file
-- @name LibSchema-1.0.lua
-- @release $Id: LibSchema-1.0.lua 9 2010-05-15 14:56:07Z bethink $


----------------------------------------------------------------------
-- Initialization

local MAJOR, MINOR = "LibSchema-1.0", 1

local LibSchema, oldMinor = LibStub:NewLibrary(MAJOR, MINOR)
if not LibSchema then
	return
end


----------------------------------------------------------------------
-- Locals

local error, setmetatable, tonumber, tostring, type
		= error, setmetatable, tonumber, tostring, type
local strformat, strlen, strmatch = string.format, string.len, string.match
local tconcat, tinsert, twipe = table.concat, table.insert, table.wipe


----------------------------------------------------------------------
-- Schema 

-- Declare the prototype and a corresponding metatable.
local TypePrototype = { }
local TypeMetatable = {
	__index = TypePrototype
}

--- Sets the optional constraint on this type. The optional constraint allows
-- the value to be nil, preventing other constraints set on this type from
-- being checked if value is nil.
-- @return this type
function TypePrototype:Optional ()
	self.optional = true
	return self
end

--- Sets a type constraint on this type. The constraint is satisfied if the
-- type of value matches the specified type. If type is a built-in type, the
-- constraint is satisfied if the type returned by the Lua type function
-- matches the specified type. If the type is a LibSchema-1.0 type, the
-- constraint is satisfied if the constraints of the LibSchema-1.0 type are
-- satisfied.
-- @param type the type, one of 'string', 'number', 'boolean', 'table',
-- 'function', 'thread', 'userdata' or a LibSchema-1.0 type
-- @return this type
function TypePrototype:Type (aType)
	if aType ~= "string" and aType ~= "number" and aType ~= "boolean"
			and aType ~= "table" and aType ~= "function" and aType ~= "thread"
			and aType ~= "userdata" and getmetatable(aType) ~= TypeMetatable
			then
		error(strformat("Usage: Type(type): 'type' - 'string', 'number', "
				.. "'boolean', 'table', 'function', 'thread', 'userdata' "
				.. "or LibSchema-1.0 type expected, got '%s'.",
				tostring(aType)), 2)
	end
	self.type = aType
	return self
end

--- Sets an integer constraint on this type. The constraint is satisfied if the
-- value is a number and the result of calculating value % 1.0 is 0.0.
-- @return this type
function TypePrototype:Integer ()
	self.integer = true
	return self
end

--- Sets a length constraint on this type. The constraint is satisfied if the
-- value is a table and the length of the table as returned by the Lua #
-- operator falls within the specified boundaries (inclusive) or if the value
-- is a string and the length of the string as returned by the Lua string.len
-- function falls within the specified boundaries (inclusive).
-- @param minLength the minimum length, or '*' if unconstrained
-- @param maxLength the maximum length, or '*' if unconstrained
-- @return this type
function TypePrototype:Length (minLength, maxLength)
	if type(minLength) == "number" and minLength < 0 or
			type(minLength) == "string" and minLength ~= "*" or
			type(minLength) ~= "number" and type(minLength) ~= "string" then
		error(strformat("Usage: Length(minLength, maxLength): 'minLength' "
				.. "- non-negative number or '*' expected, got '%s'.",
				tostring(minLength)), 2)
	end
	if type(maxLength) == "number" and maxLength < 0 or
			type(maxLength) == "string" and maxLength ~= "*" or
			type(maxLength) ~= "number" and type(maxLength) ~= "string" then
		error(strformat("Usage: Length(minLength, maxLength): 'maxLength' "
				.. "- non-negative number or '*' expected, got '%s'.",
				tostring(maxLength)), 3)
	end
	if type(minLength) == "number" and type(maxLength) == "number"
			and minLength > maxLength then
		error("Usage: Length(minLength, maxLength): 'minLength', 'maxLength' "
				.. "- minLength must be less than or equal to maxLength", 2)
	end
	self.minLength = minLength
	self.maxLength = maxLength
	return self
end

--- Sets a range constraint on this type. The constraint is satisfied if
-- the value is a number and falls within specified boundaries (inclusive).
-- @param minValue the minimum value, or '*' if unconstrained
-- @param maxValue the maximum value, or '*' if unconstrained
function TypePrototype:Range (minValue, maxValue)
	if type(minValue) == "number" and minValue < 0 or
		type(minValue) == "string" and minValue ~= "*" or
		type(minValue) ~= "number" and type(minValue) ~= "string" then
		error(strformat("Usage: Range(minValue, maxValue): 'minValue' "
				.. "- non-negative number or '*' expected, got '%s'.",
				tostring(minValue)), 2)
	end
	if type(maxValue) == "number" and maxValue < 0 or
		type(maxValue) == "string" and maxValue ~= "*" or
		type(maxValue) ~= "number" and type(maxValue) ~= "string" then
		error(strformat("Usage: Range(minValue, maxValue): 'maxValue' "
				.. "- non-negative number or '*' expected, got '%s'.",
				tostring(maxValue)), 3)
	end
	if type(minValue) == "number" and type(maxValue) == "number"
			and minValue > maxValue then
		error("Usage: Range(minValue, maxValue): 'minValue', 'maxValue' " 
				.. "- minValue must be less than or equal to maxValue", 2)
	end
	self.minValue = minValue
	self.maxValue = maxValue
	return self
end

--- Sets an enumeration constraint on this type. The constraint is satisfied if
-- the value corresponds to one of the specified values. The values are not
-- allowed to contain nil. Set the Optional constraint if you want to allow
-- a value to be nil.
-- @param ... the values
-- @return this type
function TypePrototype:Enum (...)
	self.values = { }
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if value == nil then
			error("Usage: Enum([value, ...]): 'value' - must not be nil",
					i + 1)
		end
		self.values[value] = true
	end
	return self
end

--- Sets a match constraint on this type. The constraint is satisfied if the
-- value is a string and the Lua string.match function when called with the
-- value and each of the patterns returns a successful match for at least one
-- of the patterns. Note that string.match performs substring matching.
-- Therefore, the anchoring characters '^' and '$' must be used in the patterns
-- to ensure that the value is matched in full.
-- @param ... the patterns
-- @return this type
function TypePrototype:Match (...)
	self.patterns = { }
	for i = 1, select("#", ...) do
		local pattern = select(i, ...)
		if type(pattern) ~= "string" then
			error(strformat("Usage: Match([pattern, ...]): 'pattern' "
					.. "- string expected, got '%s'.", type(pattern)), 1 + i)
		end
		self.patterns[pattern] = true
	end
	return self
end

--- Sets a custom constraint on this type. The constraint is satisfied if the
-- function when called with the value returns true. Otherwise, the function
-- must return false and provide a string describing the constraint violation
-- in the second return value.
-- @param func the custom function
-- @return this type
function TypePrototype:Custom (func)
	if type(func) ~= "function" then
		error(strformat("Usage: Custom(func): 'func' "
				.. "- function expected, got '%s'.", type(func)), 2)
	end
	self.custom = func
	return self
end

--- Sets an array constraint on this type. The array constraint is satisfied if
-- the value is a table and the constraints set on the returned array type are
-- satisified for all table values as returned by the Lua ipairs iterator.
-- @return the array type
function TypePrototype:Array ()
	local array = self.array
	if not array then
		array = { }
		setmetatable(array, TypeMetatable)
		self.array = array
	end
	return array
end

--- Sets a field constraint on this type. The field constraint is satisfied if
-- the value is a table and the constraints set on to the returned field type
-- are satisfied for the named table value. A type can have multiple field
-- constraints, provided the field names are different.
-- @param name the field name
-- @return the field type
function TypePrototype:Field (name)
	if type(name) ~= "string" then
		error(strformat("Usage: Field(name): 'name' "
				.. "- string expected, got '%s'.", type(name)), 2)
	end
	local field = { }
	setmetatable(field, TypeMetatable)
	self.fields = self.fields or { }
	self.fields[name] = field
	return field
end

local constraints = { }

--- Sets a union constraint on this type. The constraint is satisfied if the
-- following is true: the value is a table, the named table value matches one
-- of the provided union values and the value satisfies the constraints set on
-- the matched one of the returned union types. A type can have multiple union
-- constraints, provided the union field names are different.
-- @param name the union field name
-- @param ... the union values
-- @return the union types (one for each union value)
function TypePrototype:Union (name, ...)
	if type(name) ~= "string" then
		error(strformat("Usage: Union(name, [value, ...]): 'name' "
				.. "- string expected, got '%s'.", type(name)), 2)
	end
	local union = { }
	twipe(constraints)
	local constraints = { }
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if type(value) == "nil" then
			error("Usage: Union(name, [value, ...]): 'value' "
					.. "- must not be nil", i + 2)
		end
		local constraint = { }
		setmetatable(constraint, TypeMetatable)
		union[value] = constraint
		tinsert(constraints, constraint)
	end
	self.unions = self.unions or { }
	self.unions[name] = union
	return unpack(constraints)
end

--- Validates a value against this type.
-- @param value the value to validate.
-- @return true, if the value is valid, and false otherwise; if the value is
-- not valid, the second return value is a string describing the constraint
-- validation including its path.
function TypePrototype:Validate (value)
	return self:ValidatePath(value, "value")
end

-- Creates a string list from keys.
local stringList = { }
local function MakeStringList (table)
	twipe(stringList)
	for s in pairs(table) do
		tinsert(stringList, "'" .. s .. "'")
	end
	return tconcat(stringList, ", ")
end

-- Adds to a path.
local function AddToPath (path, child)
	if type(child) == "number" then
		return path .. "[" .. tostring(child) .. "]"
	else
		return path .. "." .. tostring(child)
	end
end

-- Validates a value, tracking the current path.
function TypePrototype:ValidatePath (value, path)
	-- Get type
	local valueType = type(value)
	
	-- Check optional
	if self.optional and value == nil then
		return true
	end
	
	-- Check type
	if self.type then
		if type(self.type) == "string" then
			if valueType ~= self.type then
				return false, strformat("At %s: expected '%s', got '%s'",
						path, self.type, valueType)
			end
		else
			local result, message = self.type:ValidatePath(value, path)
			if not result then
				return result, message
			end
		end
	end
	
	-- Check integer
	if self.integer then
		if valueType ~= "number" or value % 1.0 ~= 0.0 then
			return false, strformat("At %s: expected integer, got '%s'",
					path, tostring(value))
		end
	end
	
	-- Check length
	if self.minLength then
		local length
		if valueType == "string" then
			length = strlen(value)
		elseif valueType == "table" then
			length = #value
		else
			return false, strformat("At %s: expected string or table, got '%s'",
					path, valueType)
		end
		if self.minLength ~= "*" and length < self.minLength then
			return false, strformat("At %s: expected min length %d, got %d",
					path, self.minLength, length)
		end
		if self.maxLength ~= "*" and length > self.maxLength then
			return false, strformat("At %s: expected max length %d, got %d",
					path, self.maxLength, length)
		end
	end
	
	-- Check range
	if self.minValue then
		if valueType ~= "number" then
			return false, strformat("At %s: expected number, got '%s'",
					path, valueType)
		end
		if self.minValue ~= "*" and value < self.minValue then
			return false, strformat("At %s: expected min value %g, got %g",
					path, self.minValue, value)
		end
		if self.maxValue ~= "*" and value > self.maxValue then
			return false, strformat("At %s: expected max value %g, got %g",
					path, self.maxValue, value)
		end
	end
	
	-- Check enum
	if self.values then
		if not self.values[value] then
			return false, strformat("At %s: expected one of %s, got '%s'",
					path, MakeStringList(self.values), tostring(value))
		end
	end
	
	-- Check match
	if self.patterns then
		if valueType ~= "string" then
			return false, strformt("At %s: expected string, got '%s'.",
					path, valueType)
		end
		local matched = false
		for pattern in pairs(self.patterns) do
			if strmatch(value, pattern) then
				matched = true
				break
			end
		end
		if not matched then
			return false, strformat("At %s: expected string matching one of %s"
					.. ", got '%s'.", path, MakeStringList(self.patterns),
					value)
		end
	end
	
	-- Check custom
	if self.custom then
		local result, message = self.custom(value)
		if not result then
			return result, strformat("At %s: %s", path, message)
		end
	end
	
	-- Check array
	if self.array then
		if valueType ~= "table" then
			return false, strformat("At %s: expected table, got '%s'", path,
					valueType)
		end
		for index, value in ipairs(value) do
			local result, message = self.array:ValidatePath(value,
					AddToPath(path, tonumber(index)))
			if not result then
				return result, message
			end
		end
	end
	
	-- Check fields
	if self.fields then
		if valueType ~= "table" then
			return false, strformat("At %s: expected table, got '%s'", path,
					valueType)
		end
		for name, field in pairs(self.fields) do
			local result, message = field:ValidatePath(value[name],
					AddToPath(path, name))
			if not result then
				return result, message
			end
		end
	end
	
	-- Check unions
	if self.unions then
		if valueType ~= "table" then
			return false, strformat("At %s: expected table, got '%s'", path,
					valueType)
		end
		for name, union in pairs(self.unions) do
			local unionValue = value[name]
			if not unionValue then
				return false, strformat("At %s: for union '%s' "
						.. "union value is nil", path, name)
			end
			if not union[unionValue] then
				return false, strformat("At %s: for union '%s' "
						.. "expected one of %s, got '%s'", path, name,
						MakeStringList(union), tostring(unionValue))
			end
			local result, message = union[unionValue]:ValidatePath(value, path)
			if not result then
				return result, message
			end
		end
	end
	
	-- Valid
	return true
end


----------------------------------------------------------------------
-- Library

--- Returns a new schema.
-- @return the new schema
function LibSchema:NewSchema (name)
	if type(name) ~= "string" then
		error(strformat("Usage: NewSchema(name): 'name' "
				.. "- string expected, got '%s'.", type(name)), 2)
	end
	if self.__schemas[name] then
		error(strformat("Usage: NewSchame(name): 'name' "
				.. "- Schema '%s' already exists.", name), 2)
	end
	local schema = { }
	setmetatable(schema, TypeMetatable)
	self.__schemas[name] = schema
	return schema
end

--- Returns a schema by name.
-- @param name the schema name
-- @return the schema, or nil if undefined
function LibSchema:GetSchema (name)
	return self.__schemas[name]
end


--- Returns an iterator on all schemas. The method is suitable for use
-- in the Lua generic for construct.
-- @return the iterator
function LibSchema:IterateSchemas ()
	return pairs(self.__schemas)
end


----------------------------------------------------------------------
-- Library

-- Declare mixins
local mixins = {
	"NewSchema",
	"GetSchema",
	"IterateSchemas"
}

-- Tracks embeds
LibSchema.embeds = LibSchema.embeds or {}

--- Embeds the library into a target.
-- @param target the target
function LibSchema:Embed (target)
	for _, mixin in ipairs(mixins) do
		target[mixin] = self[mixin]
	end
	target.__schemas = target.__schemas or { }
	self.embeds[target] = true
	return target
end

-- Update embeds
for target, mixin in pairs(LibSchema.embeds) do
	LibSchema:Embed(target)
end