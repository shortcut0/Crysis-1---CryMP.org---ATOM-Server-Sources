--
-- SHA-1 secure hash computation on pure Lua by Adafcaefc
-- December 12, 2017
-- https://pastebin.com/7WrDFCjJ [SHA1 on pure Lua v1]
--


function trunc(input,len) -- truncate function
  local tInput = {}
  local  retval = ""
  input:gsub(".",function(c) table.insert(tInput,c) end)
  for i=0,len-1 do
    if tInput[input:len()-i] == nil then tInput[input:len()-i] = "0" end
    retval = tInput[input:len()-i]..retval
  end
  return retval
end

function decToBin(input,sLen) -- decimal to binary (specific length)
  local input = input + 1
  local n = 0
  local  retval = ""
  while 2^n < input do
    n = n + 1
  end
  for i=1,n do
    if  input - 2^(n-i) > 0 then
      input = input - 2^(n-i)
      retval = retval.."1"
    else
      retval = retval.."0"
    end
  end
  while retval:len () < sLen do
    retval = "0"..retval
  end
  return retval
end

function binToDec(input) -- binary to decimal
  local input = input:reverse()
  local retval = 0
  local tdInput = {}
  input:gsub(".",function(c) table.insert(tdInput,c) end)
  for i=0,input:len() do
    if tdInput[input:len()-i] == "1" then
      retval = retval + 2^(input:len()-i-1)
    end
  end
  return retval
end

function binToHex(input) -- binary to hex
  local retval = ""
  local ti = {}
  local convert = {
    ["0000"] = "0",
    ["0001"] = "1",
    ["0010"] = "2",
    ["0011"] = "3",
    ["0100"] = "4",
    ["0101"] = "5",
    ["0110"] = "6",
    ["0111"] = "7",
    ["1000"] = "8",
    ["1001"] = "9",
    ["1010"] = "a",
    ["1011"] = "b",
    ["1100"] = "c",
    ["1101"] = "d",
    ["1110"] = "e",
    ["1111"] = "f",
  }
  input:gsub(".",function(c) table.insert(ti,c) end)
  for i=1,math.ceil(input:len()/4) do
    retval = retval..convert[ti[4*i - 3]..ti[4*i - 2]..ti[4*i - 1]..ti[4*i]]
  end
  return retval
end

function bitNot(s1) -- Bitwise operator [NOT]
  local convert = {
    ['0'] = "1",
    ['1'] = "0"
  }
  local ts1 = {}
  local  retval = ""
  s1:gsub(".",function(c) table.insert(ts1,c) end)
  for i=1,s1:len() do
    retval = retval..convert[ts1[i]]
  end
  return retval
end

function bitAnd(s1,s2) -- Bitwise operator [AND]
  local convert = {
    ['00'] = "0",
    ['01'] = "0",
    ['10'] = "0",
    ['11'] = "1"
  }
  local ts1 = {}
  local ts2 = {}
  local  retval = ""
  s1:gsub(".",function(c) table.insert(ts1,c) end)
  s2:gsub(".",function(c) table.insert(ts2,c) end)
  for i=1,s1:len() do
    if ts1[i] == nil then
      ts1[i] = "0"
    end
    if ts2[i] == nil then
      ts2[i] = "0"
    end
    retval = retval..convert[ts1[i]..ts2[i]]
  end
  return retval
end

function bitOr(s1,s2) -- Bitwise operator [OR]
  local convert = {
    ['00'] = "0",
    ['01'] = "1",
    ['10'] = "1",
    ['11'] = "1"
  }
  local ts1 = {}
  local ts2 = {}
  local  retval = ""
  s1:gsub(".",function(c) table.insert(ts1,c) end)
  s2:gsub(".",function(c) table.insert(ts2,c) end)
  for i=1,s1:len() do
    if ts1[i] == nil then
      ts1[i] = "0"
    end
    if ts2[i] == nil then
      ts2[i] = "0"
    end
    retval = retval..convert[ts1[i]..ts2[i]]
  end
  return retval
end


function bitXor(s1,s2) -- Bitwise operator [XOR]
  local convert = {
    ['00'] = "0",
    ['01'] = "1",
    ['10'] = "1",
    ['11'] = "0"
  }
  local ts1 = {}
  local ts2 = {}
  local  retval = ""
  s1:gsub(".",function(c) table.insert(ts1,c) end)
  s2:gsub(".",function(c) table.insert(ts2,c) end)
  for i=1,s1:len() do
    if ts1[i] == nil then
      ts1[i] = "0"
    end
    if ts2[i] == nil then
      ts2[i] = "0"
    end
    retval = retval..convert[ts1[i]..ts2[i]]
  end
  return retval
end

function lrot(input,amount) -- left rotate
  local retval = ""
  local ts1 = {}
  local ts2 = {}
  input:gsub(".",function(c) table.insert(ts1,c) end)
  for i=1,amount do
    for i=1,input:len() do
      if i < input:len() then
        ts2[i] = ts1[i+1]
      else
        ts2[i] = ts1[1]
      end
    end
    ts1 = {}
    retval = table.concat(ts2)
    retval:gsub(".",function(c) table.insert(ts1,c) end)
  end
  return retval
end

function sha1(input)
  -- declaring original h0,h1,h2,h3,h4
  local h0 = "01100111010001010010001100000001"
  local h1 = "11101111110011011010101110001001"
  local h2 = "10011000101110101101110011111110"
  local h3 = "00010000001100100101010001110110"
  local h4 = "11000011110100101110000111110000"
  -- some other used variable
  local bInput = ""
  local ws = ""
  local tInput = {}
  local tbInput = {}
  local w = {}
  local ch = {}
  -- converting input to binary
  input:gsub(".",function(c) table.insert(tInput,c) end)
  for i=1,input:len() do
    bInput = bInput..decToBin(string.byte(tInput[i]),8)
  end
  -- append "1"
  bInput = bInput.."1"
  -- append "0" until the length is 448 MOD 512
  while (bInput:len()-448)/512 ~= math.ceil((bInput:len()-448)/512) do
    bInput = bInput.."0"
  end
  -- appending input length
  bInput = bInput..decToBin(input:len()*8,64)
  -- converting to chunk (size 512)
  bInput:gsub(".",function(c) table.insert(tbInput,c) end)
  for i=1,bInput:len()/512 do
    ws = ""
    for p=0,511 do
      ws = tbInput[512*i - p]..ws
    end
    ch[i] = ws
  end
  -- chunk loop
  for n=1,bInput:len()/512 do
    ws = ""
    w = {}
    tbInput = {}
    -- converting input into 16 word (size 32)
    ch[n]:gsub(".",function(c) table.insert(tbInput,c) end)
    for i=1,ch[n]:len()/32 do
      ws = ""
      for p=0,31 do
        ws = tbInput[32*i - p]..ws
      end
      w[i] = ws
    end
    -- creating 80 word (size 32)
    for i=17,80 do
      w[i] =  lrot(bitXor(w[i-16],bitXor(w[i-14],bitXor(w[i-8],w[i-3]))),1)
    end
    -- variable declaration
    local A = h0
    local B = h1
    local C = h2
    local D = h3
    local E = h4
    -- some other used variable
    local temp = 0
    local f = 0
    local k = 0
    -- main loop
    for i=1,80 do
      -- function one
      -- (B AND C) OR ((NOT B) AND D)
      if i <=20 then
        f = bitOr(bitAnd(B,C),bitAnd(bitNot(B),D))
        k = "01011010100000100111100110011001"
        -- function two
        -- B XOR C XOR D
      elseif i <=40 then
        f = bitXor(B,bitXor(C,D))
        k = "01101110110110011110101110100001"
        -- function three
        -- (B AND C) OR (B AND D) OR (C AND D)
      elseif i <=60 then
        f = bitOr(bitAnd(B,C),bitOr(bitAnd(B,D),bitAnd(C,D)))
        k = "10001111000110111011110011011100"
        -- function four
        -- B XOR C XOR D
      elseif i <=80 then
        f = bitXor(B,bitXor(C,D))
        k = "11001010011000101100000111010110"
      end
      -- creating temp variable
      temp = trunc(decToBin(tonumber(lrot(A,5),2) + tonumber(f,2) + tonumber(E,2) + tonumber(k,2) + tonumber(w[i],2),0),32)
      -- resetting A,B,C,D,E
      E = D
      D = C
      C = lrot(B,30)
      B = A
      A = temp
    end
    -- adding the last value
    h0 = trunc(decToBin(binToDec(h0) + binToDec(A),0),32)
    h1 = trunc(decToBin(binToDec(h1) + binToDec(B),0),32)
    h2 = trunc(decToBin(binToDec(h2) + binToDec(C),0),32)
    h3 = trunc(decToBin(binToDec(h3) + binToDec(D),0),32)
    h4 = trunc(decToBin(binToDec(h4) + binToDec(E),0),32)
  end
  -- return hex value
  return binToHex(h0..h1..h2..h3..h4)
end
