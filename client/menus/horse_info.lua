function HorseInfoMenu()
    local horseHealth = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 0, Citizen.ResultAsInteger()) -- GetAttributeCoreValue
    local horseStamina = Citizen.InvokeNative(0x36731AC041289BB1, MyHorse, 1, Citizen.ResultAsInteger()) -- GetAttributeCoreValue
    local currentLevel = Citizen.InvokeNative(0x147149F2E909323C, MyHorse, 7, Citizen.ResultAsInteger()) -- GetAttributeBaseRank
    local currentXp = Citizen.InvokeNative(0x219DA04BAA9CB065, MyHorse, 7, Citizen.ResultAsInteger()) -- GetAttributePoints

    local bondingLevels = {
        Citizen.InvokeNative(0x94A7F191DB49A44D, MyModel, 7, 1), -- GetDefaultAttributePointsNeededForRank / Bonding Level
        Citizen.InvokeNative(0x94A7F191DB49A44D, MyModel, 7, 2),
        Citizen.InvokeNative(0x94A7F191DB49A44D, MyModel, 7, 3),
        Citizen.InvokeNative(0x94A7F191DB49A44D, MyModel, 7, 4)
    }

    local infoMenu = FeatherMenu:RegisterMenu('bcc-stables:HorseInfoMenu', {
        top = '3%',
        left = '3%',
        ['720width'] = '400px',
        ['1080width'] = '500px',
        ['2kwidth'] = '600px',
        ['4kwidth'] = '800px',
        style = {},
        contentslot = {
            style = {
                ['height'] = '325px',
                ['min-height'] = '325px'
            }
        },
        draggable = true,
        canclose = true
    })

    local homePage = infoMenu:RegisterPage('home:page')

    local headerStyle = {
        ['color'] = '#ddd'
    }

    local textDisplayStyle = {
        ['color'] = '#C0C0C0',
        ['font-variant'] = 'small-caps',
        ['font-size'] = '16px'
    }

    homePage:RegisterElement('header', {
        value = HorseName,
        slot = 'header',
        style = headerStyle
    })

    homePage:RegisterElement('subheader', {
        value = MyHorseBreed,
        slot = 'header',
        style = headerStyle
    })

    homePage:RegisterElement('textdisplay', {
        value = _U('horseInfoCoat') .. MyHorseColor,
        slot = 'header',
        style = textDisplayStyle
    })

    homePage:RegisterElement('textdisplay', {
        value = _U('horseInfoHealth') .. horseHealth .. ' | ' .. _U('horseInfoStamina') .. horseStamina,
        slot = 'header',
        style = textDisplayStyle
    })

    homePage:RegisterElement('textdisplay', {
        value = _U('horseInfoLevel') .. currentLevel .. ' | ' .. _U('horseInfoCurXp') .. currentXp,
        slot = 'header',
        style = textDisplayStyle
    })

    homePage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    homePage:RegisterElement('subheader', {
        value = _U('horseInfoBondLevels'),
        slot = 'content',
        style = headerStyle
    })

    local bondingLevelTexts = {
        _U('horseInfoLvl_1') .. bondingLevels[1] .. _U('horseInfoXp'),
        _U('horseInfoLvl_2') .. bondingLevels[2] .. _U('horseInfoXp') .. '\n' .. _U('horseInfoTrickLvl_2'),
        _U('horseInfoLvl_3') .. bondingLevels[3] .. _U('horseInfoXp') .. '\n' .. _U('horseInfoTrickLvl_3'),
        _U('horseInfoLvl_4') .. bondingLevels[4] .. _U('horseInfoXp') .. '\n' .. _U('horseInfoTrickLvl_4a') .. '\n' .. _U('horseInfoTrickLvl_4b')
    }

    for _, text in ipairs(bondingLevelTexts) do
        homePage:RegisterElement('textdisplay', {
            value = text,
            slot = 'content',
            style = textDisplayStyle
        })
    end

    homePage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    infoMenu:Open({
        startupPage = homePage
    })
end
