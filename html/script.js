$('#creatormenu').fadeOut(0);

window.addEventListener('message', function(event) {
    if (event.data.action == "show") {
        $("#creatormenu").fadeIn(500);
       
        if (event.data.shopData) {
            for (const [index, table] of Object.entries(event.data.shopData)) {
                var horseCategory = table.name

                if ($(`#page_shop .scroll-container .collapsible #${index}`).length <= 0) {
                    $('#page_shop .scroll-container .collapsible').append(`
                         <li id="${index}">
                            <div class="collapsible-header col s12 panel ">
                                <div class="col s12 panel-title">
                                    <h6 class="grey-text">${horseCategory}</h6>
                                </div>
                            </div>
                            <div class="collapsible-body item-bg">
                            </div>
                        </li>
                    `);
                }

                for (const [_, horseData] of Object.entries(table)) {
                    if (_ != 'name') {
                        let Modelhorse
                        var HorseName = horseData.version;
                        var priceCash = horseData.cashPrice;
                        var priceGold = horseData.goldPrice;
                     
                        $(`#page_shop .scroll-container .collapsible #${index} .collapsible-body`).append(`

                            <div id="${_}" onhover="loadHorse(this)" class="col s12 panel item1">

                                <div class="col s6 panel-col item2">
                                    <h6 class="grey-text title" style="color:white;">${HorseName}</h6>
                                </div>          

                                <div class="buy-buttons">     
                                    <button class="btn-small"  onclick="buyHorse('${_}', ${priceCash}, true)">
                                        <img src="img/money.png"><span class="horse-price">${priceCash}</span>
                                    </button>                                  
                                    <button class="btn-small"  onclick="buyHorse('${_}', ${priceGold}, false)">                                                
                                        <img src="img/gold.png"><span class="horse-price">${priceGold}</span>
                                    </button>                                          
                                </div>
                                
                            </div>
                        `);

                        $(`#page_shop .scroll-container .collapsible #${index} .collapsible-body #${_}`).hover(function() {                       
                            $( this ).click(function() {                        
                             
                                $(Modelhorse).addClass("selected");
                                $('.selected').removeClass("selected"); 

                                Modelhorse = $(this).attr('id');                       
                                $(this).addClass('selected');

                                $.post('http://oss_stables/loadHorse', JSON.stringify({ horseModel: $(this).attr('id') }));
                            });                       
                            
                        }, function() {});
                    }
                }
            }
            $('#page_myhorses .scroll-container .collapsible').html('');
            $('.collapsible').collapsible();
        }
        if (event.data.action == "hide") {
            $("#creatormenu").fadeOut(500);
        }
    }

    

    if (event.data.EnableCustom == "true") {
        $('#button-customization').removeClass("disabled");
    } else {
        $('#button-customization').addClass("disabled");
    }
    
    if (event.data.myHorsesData) {

        for (const [ind, tab] of Object.entries(event.data.myHorsesData)) {
        
            let HorseName = tab.name;
            let HorseID = tab.id;
            let HorseIdModel = tab.model;
            let componentsh = tab.components;

            $('#page_myhorses .scroll-container .collapsible').append(`
                <li>
                    <div id="heads" class="collapsible-header col s12 panel" style="background-color: transparent; border: 0;">
                        <div class="col s12 panel-title">
                            <h6 class="grey-text">${HorseName}</h6>
                        </div>
                    </div>
                    <div class="collapsible-body col s12 panel item1" id="${HorseID}">
                        <div class="col s6 panel-col item2" onclick="SelectHorse(${HorseID})">
                            <h6 class="grey-text title">Select</h6>
                        </div>
                        <div class="col s6 panel-col item2" onclick="SellHorse(${HorseID})">
                            <h6 class="grey-text title">Sell</h6>
                        </div>
                    </div>
                </li> 
            `);
            
            $(`#page_myhorses .scroll-container .collapsible #${HorseID}`).hover(function() {  
                $( this ).click(function() { 
                    $(HorseID).addClass("selected");
                    $('.selected').removeClass("selected");             
                    $(HorseID).addClass('selected');

                    $.post('http://oss_stables/loadMyHorse', JSON.stringify({ IdHorse: HorseID, horseModel: HorseIdModel, HorseComp: componentsh}));
                });                         
            }, function() {});
        }
    }
});

function confirm(){
    $.post('http://oss_stables/CloseStable')

    $('#button-customization').addClass("disabled");
    $('#page_myhorses .scroll-container .collapsible').html('');
    $('#page_shop .scroll-container .collapsible').html('');
    $("#creatormenu").fadeOut(500);
}

function rotate(){
    $.post('http://oss_stables/rotate')

    $('#button-customization').addClass("disabled");
}

var currentPage = 'page_myhorses';

$('.menu-selectb').on('click', function() {
    $(`#${currentPage}`).hide();

    currentPage = $(this).data('target');
    $(`#${currentPage}`).show();

    $('.menu-selectb.active').removeClass('active');
    $(this).addClass('active');
});

$(".button-right").on('click', function() {
    var inputElement = $(this).parent().find('input');
    var component = $(inputElement).attr('id');

    var value = Number($(inputElement).attr('value'));
    // value = Number(String.split(value, '/')[0]);
    var nValue = value + 1;

    var min = $(inputElement).attr('min');
    var max = $(inputElement).attr('max');

    if (nValue > max) {
        nValue = min;
    }

    $(inputElement).attr('value', nValue);

    var titleElement = $(this).parent().parent().find('.grey-text');
    var text = titleElement.text();
  //  var component = text.split(' ')[0];
    titleElement.text(component + ' ' + nValue + '/' + max);
    $.post('http://oss_stables/'+component, JSON.stringify({ id: nValue }));
});

$(".button-left").on('click', function() {
    var inputElement = $(this).parent().find('input');
    var component = $(inputElement).attr('id');

    var value = Number($(inputElement).attr('value'));

    var nValue = value - 1;

    var min = $(inputElement).attr('min');
    var max = $(inputElement).attr('max');

    if (nValue < min) {
        nValue = max;
    }

    $(inputElement).attr('value', nValue);

    var titleElement = $(this).parent().parent().find('.grey-text');
    var text = titleElement.text();

    titleElement.text(component + ' ' + nValue + '/' + max);
    $.post('http://oss_stables/'+component, JSON.stringify({ id: nValue }));
});

$(".input-number").on("change paste keyup", function() {

    var min = Number($(this).attr('min'));
    var max = Number($(this).attr('max'));

    var value = $(this).val();

    if (value == '' || value < min) {
        value = min;
        $(this).val(value);
    }

    if (value > max) {
        value = max;
        $(this).val(value);
    }

    var titleElement = $(this).parent().parent().find('.grey-text');
    var text = titleElement.text();    
    var component = text.split(' ')[0];
    
    titleElement.text(component + ' ' + value + '/' + max);

});

function buyHorse(Modelhor, price, isCash) {        
    $('#button-customization').addClass("disabled");
    $('#page_myhorses .scroll-container .collapsible').html('');
    $('#page_shop .scroll-container .collapsible').html('');
    $("#creatormenu").fadeOut(500);

    if (isCash) {        
        $.post('http://oss_stables/BuyHorse', JSON.stringify({ ModelH: Modelhor, Cash: price, IsCash: isCash }));
    } else {
        $.post('http://oss_stables/BuyHorse', JSON.stringify({ ModelH: Modelhor, Gold: price, IsCash: isCash }));    
    }    
}

function SelectHorse(IdHorse) {    
    $.post('http://oss_stables/selectHorse', JSON.stringify({ horseID: IdHorse }))    
}

function SellHorse(IdHorse) {    
    $.post('http://oss_stables/sellHorse', JSON.stringify({ horseID: IdHorse }))

    $('#button-customization').addClass("disabled");
    $('#page_myhorses .scroll-container .collapsible').html('');
    $('#page_shop .scroll-container .collapsible').html('');
    $("#creatormenu").fadeOut(500);

}
