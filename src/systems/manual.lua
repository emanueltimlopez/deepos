local Manual = {}
Manual.__index = Manual

function Manual.new()
    local self = setmetatable({}, Manual)
    self.level = 1 -- v1 free, v2 and v3 purchasable
    return self
end

function Manual:getLevel()
    return self.level
end

function Manual:setLevel(level)
    self.level = math.max(self.level, level)
end

function Manual:getPages()
    local pages = {}

    -- Page 1 (v1 - always available)
    pages[1] = {
        title = "Manual.txt v1 - Basic Patterns",
        lines = {
            "== SYGNAL OS FIELD MANUAL ==",
            "",
            "JUNK SIGNATURES (discard these):",
            "  00 00 00 00  - Empty sectors",
            "  FF FF FF FF  - Dead blocks",
            "  00 FF 00 FF  - Null patterns",
            "  Repeating 0/F = no value",
            "",
            "KNOWN VIRUS SIGNATURES:",
            "  TROJAN.V3  - Trojan payload",
            "  WORM.X1    - Worm replicator",
            "  ROOTKIT    - Root exploit",
            "  MALWARE.Z  - Generic malware",
            "  SPYWARE.Q  - Spyware agent",
            "",
            "WARNING: If you see a virus",
            "pattern during decrypt, ABORT",
            "immediately! Past 60% the",
            "virus executes and crashes",
            "your system.",
            "",
            "TIP: Preview hex in inbox to",
            "spot junk before opening.",
        },
    }

    -- Page 2 (v2 - purchasable)
    if self.level >= 2 then
        pages[2] = {
            title = "Manual.txt v2 - Advanced Analysis",
            lines = {
                "== ADVANCED PATTERN ANALYSIS ==",
                "",
                "FALSE POSITIVES:",
                "  Some leads look like junk but",
                "  contain valuable data (20%",
                "  snapshot mismatch rate).",
                "",
                "  A 'basura' preview might hide",
                "  a rare payload. Don't trash",
                "  everything that looks dead.",
                "",
                "VALID DATA HEADERS:",
                "  4x-7x range = ASCII printable",
                "  Dense varied hex = likely data",
                "  Mixed 4/5/6/7 = standard lead",
                "",
                "STANDARD vs BASURA:",
                "  Standard has ASCII-range hex",
                "  mixed with noise. Basura is",
                "  mostly 00 and FF repeating.",
                "",
                "TRACE MANAGEMENT:",
                "  Each open window adds trace.",
                "  Jackpot leads add EXTRA trace.",
                "  Close windows you don't need.",
            },
        }
    end

    -- Page 3 (v3 - purchasable)
    if self.level >= 3 then
        pages[3] = {
            title = "Manual.txt v3 - Expert Signatures",
            lines = {
                "== EXPERT FIELD REFERENCE ==",
                "",
                "RARE LEAD MARKERS:",
                "  Dense hex with NO 0 or F",
                "  All chars in 1-E range",
                "  Very few repeated bytes",
                "",
                "JACKPOT MARKERS:",
                "  Structured blocks with E",
                "  headers every 16 chars",
                "  High concentration of",
                "  A,B,C,D,E,8,9,3,7",
                "",
                "JACKPOT IDENTIFICATION:",
                "  Look for 'E' at positions",
                "  0 and 1 of each 16-byte row.",
                "  This is the genesis header.",
                "",
                "VALUE ESTIMATION:",
                "  Basura:   20-80 CR",
                "  Standard: 100-300 CR",
                "  Rare:     400-800 CR",
                "  Jackpot:  1000-3000 CR",
                "",
                "Remember: 20% of previews lie.",
            },
        }
    end

    return pages
end

function Manual:getPageCount()
    return self.level
end

function Manual:serialize()
    return { level = self.level }
end

function Manual:deserialize(data)
    self.level = data.level or 1
end

return Manual
