(function(){"use strict";var e={7185:function(e,t,s){var o=s(9242),i=s(3396);const a={key:0,id:"content"};function l(e,t,s,o,l,n){const r=(0,i.up)("router-view");return l.visible||l.devmode?((0,i.wg)(),(0,i.iD)("div",a,[(0,i.Wm)(r)])):(0,i.kq)("",!0)}var n={name:"DefaultLayout",data(){return{devmode:!1,visible:!1}},mounted(){window.addEventListener("message",this.onMessage)},methods:{onMessage(e){switch(e.data.action){case"show":this.visible=!0,this.$store.dispatch("setHorses",e.data.shopData),this.$store.dispatch("setShopName",e.data.location),this.$store.dispatch("setComponents",Object.fromEntries(Object.entries(e.data.compData).sort())),this.$store.dispatch("setCurrencyType",e.data.currencyType);break;case"updateMyHorses":this.$store.dispatch("setMyHorses",e.data.myHorsesData);break;case"hide":this.visible=!1,this.$store.dispatch("setMyHorses",null),this.$store.dispatch("setHorses",null),this.$store.dispatch("setShopName",null),this.$store.dispatch("setComponents",null),this.$store.dispatch("setSelectedHorse",null),this.$store.dispatch("setCompCashPrice",0),this.$store.dispatch("setCompGoldPrice",0),this.$store.dispatch("setShowTackPrice",!1),this.$store.dispatch("setAllowSave",!1),this.$store.dispatch("setCurrencyType",null);break;default:break}}}},r=s(89);const c=(0,r.Z)(n,[["render",l]]);var d=c,h=s(2483),u=s(7139);const m=e=>((0,i.dD)("data-v-7287d9d7"),e=e(),(0,i.Cn)(),e),p={class:"container"},v={class:"main"},g={class:"header"},b={class:"header-text"},_={class:"btn-menu main-nav-buttons"},f=m((()=>(0,i._)("div",{class:"divider-menu-top"},null,-1))),C={key:0,class:"scroll-container"},y={key:1,class:"scroll-container"},w={key:2,class:"scroll-container"},S=m((()=>(0,i._)("div",{class:"divider-menu-top",style:{"margin-top":"1rem"}},null,-1))),M={class:"btn-bottom-main btn-bottom"},k=["disabled"],x=m((()=>(0,i._)("i",{class:"fas fa-chevron-left center"},null,-1))),T=[x],P=m((()=>(0,i._)("div",{class:"rotate-text"},[(0,i._)("span",{class:"grey-text center"},"Rotate")],-1))),H=m((()=>(0,i._)("i",{class:"fas fa-chevron-right center"},null,-1))),E=[H],I=m((()=>(0,i._)("div",{class:"divider-menu-bottom"},null,-1))),O=m((()=>(0,i._)("p",{style:{"text-align":"center"}},"Purchase by selecting cash or gold.",-1))),D=m((()=>(0,i._)("div",{class:"divider-menu-top",style:{"margin-top":"1rem"}},null,-1))),G={class:"flex cta-wrapper"},$=m((()=>(0,i._)("img",{src:"img/money.png"},null,-1))),R=m((()=>(0,i._)("img",{src:"img/gold.png"},null,-1))),N=m((()=>(0,i._)("div",{class:"divider-menu-bottom"},null,-1)));function j(e,t,s,o,a,l){const n=(0,i.up)("MenuButton"),r=(0,i.up)("MyStableMenu"),c=(0,i.up)("TraderMenu"),d=(0,i.up)("TackShopMenu"),h=(0,i.up)("ConfirmationModal");return(0,i.wg)(),(0,i.iD)("div",p,[(0,i._)("div",v,[(0,i._)("div",g,[(0,i._)("div",b,(0,u.zw)(e.shopName),1)]),(0,i._)("div",_,[(0,i.Wm)(n,{label:"Stable",selectedPage:a.page,onClick:t[0]||(t[0]=e=>a.page="Stable"),class:"enabled"},null,8,["selectedPage"]),(0,i.Wm)(n,{label:"Trader",selectedPage:a.page,onClick:t[1]||(t[1]=e=>a.page="Trader"),class:"enabled"},null,8,["selectedPage"]),(0,i.Wm)(n,{label:"Tack Shop",selectedPage:a.page,onClick:t[2]||(t[2]=e=>a.page="Tack Shop"),class:(0,u.C_)({"disabled-btn":l.isClosed,enabled:!l.isClosed}),disabled:l.isClosed},null,8,["selectedPage","class","disabled"])]),f,"Stable"==a.page?((0,i.wg)(),(0,i.iD)("div",C,[(0,i.Wm)(r)])):"Trader"==a.page?((0,i.wg)(),(0,i.iD)("div",y,[(0,i.Wm)(c)])):((0,i.wg)(),(0,i.iD)("div",w,[(0,i.Wm)(d)])),S,(0,i._)("div",M,[(0,i._)("button",{id:"save",onClick:t[3]||(t[3]=e=>l.save()),disabled:!l.isSaveEnabled,class:(0,u.C_)({disabled:!l.isSaveEnabled,"btn-select":l.isSaveEnabled})}," Save ",10,k),(0,i._)("button",{id:"rotate_left",class:"btn-select btn-rotate",onMousedown:t[4]||(t[4]=e=>l.startRotate("left")),onMouseleave:t[5]||(t[5]=(...e)=>l.onMouseLeave&&l.onMouseLeave(...e))},T,32),P,(0,i._)("button",{id:"rotate_right",class:"btn-select btn-rotate",onMousedown:t[6]||(t[6]=e=>l.startRotate("right")),onMouseleave:t[7]||(t[7]=(...e)=>l.onMouseLeave&&l.onMouseLeave(...e))},E,32),(0,i._)("button",{id:"cancel",class:"btn-select",onClick:t[8]||(t[8]=e=>l.close())},"Cancel")]),I]),(0,i.Wm)(h,{visible:a.showModal,title:"Purchase",onClose:t[12]||(t[12]=e=>l.hideModal())},{default:(0,i.w5)((()=>[O,D,(0,i._)("div",G,[(0,i._)("button",{onClick:t[9]||(t[9]=e=>l.purchase(0)),class:"modal-btn flex flex-auto"},[$,(0,i.Uk)((0,u.zw)(e.compCashPrice),1)]),(0,i._)("button",{onClick:t[10]||(t[10]=e=>l.purchase(1)),class:"modal-btn flex flex-auto"},[R,(0,i.Uk)((0,u.zw)(e.compGoldPrice),1)]),(0,i._)("button",{onClick:t[11]||(t[11]=(...e)=>l.hideModal&&l.hideModal(...e)),class:"modal-btn flex flex-auto"},(0,u.zw)(l.isSaveEnabled?"Cancel":"Close"),1)]),N])),_:1},8,["visible"])])}var A=s(65),W=s(6265),z=s.n(W);const q=z().create({baseURL:`https://${"undefined"!==typeof GetParentResourceName?GetParentResourceName():"bcc-stables"}/`});var L=q;function Z(e,t,s,o,a,l){return(0,i.wg)(),(0,i.iD)("button",{class:(0,u.C_)({active:l.isActive})},(0,u.zw)(s.label),3)}var U={name:"MenuButton",props:{label:String,selectedPage:String},computed:{isActive(){return this.label==this.selectedPage}}};const Y=(0,r.Z)(U,[["render",Z],["__scopeId","data-v-33c26727"]]);var V=Y;const B=e=>((0,i.dD)("data-v-0ae3960c"),e=e(),(0,i.Cn)(),e),K={key:0},J={key:0},F={key:1},Q=(0,i.uE)('<div class="text" data-v-0ae3960c><div class="container" data-v-0ae3960c><div class="flex panel" data-v-0ae3960c><div class="flex flex-auto panel-title" data-v-0ae3960c><h6 class="grey-text plus" data-v-0ae3960c> No Horses!  Head to the Trader </h6></div></div></div></div>',1),X=[Q],ee={key:1},te=B((()=>(0,i._)("img",{src:"img/6cyl_revolver.png",alt:"",class:"image"},null,-1))),se=[te];function oe(e,t,s,o,a,l){const n=(0,i.up)("MyStableMenuItem");return e.myHorses?((0,i.wg)(),(0,i.iD)("div",K,[Object.keys(e.myHorses).length?((0,i.wg)(),(0,i.iD)("div",J,[(0,i._)("div",null,[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(e.myHorses,((e,s)=>((0,i.wg)(),(0,i.j4)(n,{label:e.name,index:e.id,model:e.model,horse:e,components:JSON.parse(e.components),selected:a.activeDropdown,key:s,onIExpanded:t[0]||(t[0]=e=>l.onChildExpansion(e))},null,8,["label","index","model","horse","components","selected"])))),128))])])):((0,i.wg)(),(0,i.iD)("div",F,X))])):((0,i.wg)(),(0,i.iD)("div",ee,se))}const ie=e=>((0,i.dD)("data-v-6eed6264"),e=e(),(0,i.Cn)(),e),ae={class:"container"},le={class:"panel"},ne={class:"grey-text plus"},re={key:0,class:"fas fa-chevron-left center active-horse mr"},ce={key:1,class:"fas fa-chevron-right center active-horse ml"},de={key:0,class:"mb"},he=ie((()=>(0,i._)("div",null,null,-1))),ue={class:"panel-myhorse item"},me=ie((()=>(0,i._)("div",{class:""},null,-1))),pe=ie((()=>(0,i._)("p",{style:{"text-align":"center"}},"Are you sure you want to sell?",-1))),ve=ie((()=>(0,i._)("div",{class:"divider-menu-top",style:{"margin-top":"1rem"}},null,-1))),ge={class:"flex cta-wrapper"},be=ie((()=>(0,i._)("img",{src:"img/money.png"},null,-1))),_e=ie((()=>(0,i._)("div",{class:"divider-menu-bottom"},null,-1)));function fe(e,t,s,o,a,l){const n=(0,i.up)("GenderIndicator"),r=(0,i.up)("ConfirmationModal");return(0,i.wg)(),(0,i.iD)(i.HY,null,[(0,i._)("div",ae,[(0,i._)("div",le,[(0,i._)("div",{class:"panel-title",onClick:t[0]||(t[0]=e=>[l.SelectHorse(),l.Expand()])},[(0,i._)("h6",ne,[l.isActive?((0,i.wg)(),(0,i.iD)("i",re)):(0,i.kq)("",!0),(0,i.Uk)(" "+(0,u.zw)(s.label)+" ",1),(0,i.Wm)(n,{gender:s.horse.gender},null,8,["gender"]),l.isActive?((0,i.wg)(),(0,i.iD)("i",ce)):(0,i.kq)("",!0)])])]),l.isOpen?((0,i.wg)(),(0,i.iD)("div",de,[he,(0,i._)("div",ue,[(0,i._)("button",{class:"item-myhorse",onClick:t[1]||(t[1]=e=>l.RenameHorse())},"Rename"),(0,i._)("button",{class:"item-myhorse",onClick:t[2]||(t[2]=(...e)=>l.toggleModal&&l.toggleModal(...e))},"Sell")]),me])):(0,i.kq)("",!0)]),(0,i.Wm)(r,{visible:a.showModal,title:"Confirm",onClose:l.toggleModal},{default:(0,i.w5)((()=>[pe,ve,(0,i._)("div",ge,[(0,i._)("button",{onClick:t[3]||(t[3]=(...e)=>l.SellHorse&&l.SellHorse(...e)),class:"modal-btn flex flex-auto"},[be,(0,i.Uk)("Sell ")]),(0,i._)("button",{onClick:t[4]||(t[4]=(...e)=>l.toggleModal&&l.toggleModal(...e)),class:"modal-btn flex flex-auto"}," Cancel ")]),_e])),_:1},8,["visible","onClose"])],64)}const Ce={key:0,class:"modal-wrapper"},ye={class:"modal"},we={class:"modal-header"},Se={class:"modal-body"};function Me(e,t,s,o,a,l){return s.visible?((0,i.wg)(),(0,i.iD)("div",Ce,[(0,i._)("div",{class:"modal-overlay",onClick:t[0]||(t[0]=(...e)=>l.close&&l.close(...e))}),(0,i._)("div",ye,[(0,i._)("div",we,[(0,i._)("span",null,(0,u.zw)(s.title),1)]),(0,i._)("div",Se,[(0,i.WI)(e.$slots,"default",{},void 0,!0)])])])):(0,i.kq)("",!0)}var ke={name:"ConfirmationModal",props:{visible:{type:Boolean,required:!0},title:{type:String,default:"Modal Title"}},methods:{close(){this.$emit("update:visible",!1)}},computed:{isActive(){return this.label==this.selectedPage}}};const xe=(0,r.Z)(ke,[["render",Me],["__scopeId","data-v-4dfe12d2"]]);var Te=xe;const Pe={key:0,width:"20px",height:"20px",viewBox:"0 0 1024 1024",xmlns:"http://www.w3.org/2000/svg",style:{"vertical-align":"middle"}},He=(0,i._)("path",{fill:"#9e9e9e",d:"M399.5 849.5a225 225 0 1 0 0-450 225 225 0 0 0 0 450zm0 56.25a281.25 281.25 0 1 1 0-562.5 281.25 281.25 0 0 1 0 562.5zm253.125-787.5h225q28.125 0 28.125 28.125T877.625 174.5h-225q-28.125 0-28.125-28.125t28.125-28.125z"},null,-1),Ee=(0,i._)("path",{fill:"#9e9e9e",d:"M877.625 118.25q28.125 0 28.125 28.125v225q0 28.125-28.125 28.125T849.5 371.375v-225q0-28.125 28.125-28.125z"},null,-1),Ie=(0,i._)("path",{fill:"#9e9e9e",d:"M604.813 458.9 565.1 419.131l292.613-292.668 39.825 39.824z"},null,-1),Oe=[He,Ee,Ie],De={key:1,width:"25px",height:"25px",viewBox:"0 0 24 24",fill:"none",xmlns:"http://www.w3.org/2000/svg",style:{"vertical-align":"middle"}},Ge=(0,i._)("path",{d:"M9 18H15M12 13V21M12 13C14.7614 13 17 10.7614 17 8C17 5.23858 14.7614 3 12 3C9.23858 3 7 5.23858 7 8C7 10.7614 9.23858 13 12 13Z",stroke:"#9e9e9e","stroke-width":"1.5","stroke-linecap":"round","stroke-linejoin":"round"},null,-1),$e=[Ge];function Re(e,t,s,o,a,l){return"male"==s.gender?((0,i.wg)(),(0,i.iD)("svg",Pe,Oe)):((0,i.wg)(),(0,i.iD)("svg",De,$e))}var Ne={name:"MyStableMenuItem",props:{gender:String}};const je=(0,r.Z)(Ne,[["render",Re]]);var Ae=je,We={name:"MyStableMenuItem",props:{label:String,index:Number,model:String,components:Object,selected:Number,horse:Object},data(){return{showModal:!1}},emits:["iExpanded"],computed:{...(0,A.rn)(["activeHorse"]),isOpen(){return this.index==this.selected},isActive(){return this.activeHorse&&this.index==this.activeHorse["id"]}},methods:{Expand(){this.isOpen||this.$emit("iExpanded",this.index)},SelectHorse(){this.isOpen||(this.$store.dispatch("setSelectedHorse",this.horse),L.post("selectHorse",{horseId:this.index}).catch((e=>{console.log(e.message)})),L.post("loadMyHorse",{HorseId:this.index,HorseModel:this.model,HorseGender:this.horse.gender,HorseComp:JSON.stringify(this.components)}))},RenameHorse(){L.post("RenameHorse",{horseId:this.index}).catch((e=>{console.log(e.message)}))},SellHorse(){L.post("sellHorse",{horseId:this.index}).catch((e=>{console.log(e.message)}))},toggleModal(){this.showModal=!this.showModal}},components:{ConfirmationModal:Te,GenderIndicator:Ae}};const ze=(0,r.Z)(We,[["render",fe],["__scopeId","data-v-6eed6264"]]);var qe=ze,Le={name:"MyStableMenu",data(){return{activeDropdown:-1}},methods:{onChildExpansion(e){this.activeDropdown=e}},components:{MyStableMenuItem:qe},computed:(0,A.rn)(["myHorses","activeHorse"])};const Ze=(0,r.Z)(Le,[["render",oe],["__scopeId","data-v-0ae3960c"]]);var Ue=Ze;function Ye(e,t,s,o,a,l){const n=(0,i.up)("TraderMenuItem");return(0,i.wg)(),(0,i.iD)("div",null,[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(e.horses,((e,t)=>((0,i.wg)(),(0,i.j4)(n,{horse:e,index:t,selected:a.activeDropdown,key:t,onIExpanded:e=>l.onChildExpansion(e,t)},null,8,["horse","index","selected","onIExpanded"])))),128))])}const Ve={class:"container"},Be={class:"flex flex-auto panel-title"},Ke={class:"grey-text plus"},Je={key:0};function Fe(e,t,s,o,a,l){const n=(0,i.up)("TraderMenuColor");return(0,i.wg)(),(0,i.iD)("div",Ve,[(0,i._)("div",{class:"flex panel",onClick:t[0]||(t[0]=e=>l.Expand())},[(0,i._)("div",Be,[(0,i._)("h6",Ke,(0,u.zw)(s.horse.breed),1)])]),l.isOpen?((0,i.wg)(),(0,i.iD)("div",Je,[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(s.horse.colors,((e,t)=>((0,i.wg)(),(0,i.iD)("div",{class:"item",key:t},[(0,i.Wm)(n,{horse:e,model:t},null,8,["horse","model"])])))),128))])):(0,i.kq)("",!0)])}const Qe=e=>((0,i.dD)("data-v-c1472e84"),e=e(),(0,i.Cn)(),e),Xe={class:"item flex flex-auto"},et={class:"grey-text-shop title"},tt={class:"buy-buttons flex flex-auto justify-end"},st=Qe((()=>(0,i._)("img",{src:"img/money.png",class:"ml-1"},null,-1))),ot={class:"ml-1"},it=Qe((()=>(0,i._)("img",{src:"img/gold.png",class:"ml-1"},null,-1))),at={class:"ml-1"},lt=Qe((()=>(0,i._)("div",{class:"divider-menu-top",style:{"margin-top":"1rem"}},null,-1))),nt={class:"flex cta-wrapper"},rt=Qe((()=>(0,i._)("div",{class:"divider-menu-bottom"},null,-1))),ct=Qe((()=>(0,i._)("div",{class:"divider-menu-top",style:{"margin-top":"1rem"}},null,-1))),dt={class:"flex cta-wrapper"},ht=Qe((()=>(0,i._)("div",{class:"divider-menu-bottom"},null,-1)));function ut(e,t,s,o,a,l){const n=(0,i.up)("ConfirmationModal");return(0,i.wg)(),(0,i.iD)(i.HY,null,[(0,i._)("div",{class:"panel-shop item flex",onClick:t[2]||(t[2]=e=>l.loadHorse())},[(0,i._)("div",Xe,[(0,i._)("h6",et,(0,u.zw)(s.horse.color),1)]),(0,i._)("div",tt,[l.useCash?((0,i.wg)(),(0,i.iD)("button",{key:0,style:{display:"flex","justify-content":"flex-start"},class:(0,u.C_)(["btn-small",{mr:!l.useGold}]),onClick:t[0]||(t[0]=t=>e.openConfirmationModal(!0))},[st,(0,i._)("span",ot,(0,u.zw)(s.horse.cashPrice),1)],2)):(0,i.kq)("",!0),l.useGold?((0,i.wg)(),(0,i.iD)("button",{key:1,style:{display:"flex","justify-content":"flex-start"},class:"btn-small right-btn",onClick:t[1]||(t[1]=t=>e.openConfirmationModal(!1))},[it,(0,i._)("span",at,(0,u.zw)(s.horse.goldPrice),1)])):(0,i.kq)("",!0)])]),(0,i.Wm)(n,{visible:a.isVisible,title:"Purchase",onClose:t[5]||(t[5]=e=>l.hideModal())},{default:(0,i.w5)((()=>[lt,(0,i._)("div",nt,[(0,i._)("button",{onClick:t[3]||(t[3]=e=>l.buyHorse()),class:"modal-btn flex flex-auto"}," Confirm "),(0,i._)("button",{onClick:t[4]||(t[4]=(...e)=>l.hideModal&&l.hideModal(...e)),class:"modal-btn flex flex-auto"}," Cancel ")]),rt])),_:1},8,["visible"]),(0,i.Wm)(n,{visible:a.genderVisible,title:"Select Gender",onClose:t[9]||(t[9]=e=>l.hideGenderModal())},{default:(0,i.w5)((()=>[ct,(0,i._)("div",dt,[(0,i._)("button",{onClick:t[6]||(t[6]=e=>l.setGender("male")),class:"modal-btn flex flex-auto"}," Male "),(0,i._)("button",{onClick:t[7]||(t[7]=e=>l.setGender("female")),class:"modal-btn flex flex-auto"}," Female "),(0,i._)("button",{onClick:t[8]||(t[8]=(...e)=>l.hideGenderModal&&l.hideGenderModal(...e)),class:"modal-btn flex flex-auto"}," Cancel ")]),ht])),_:1},8,["visible"])],64)}var mt={name:"TraderMenuColor",props:{horse:Object,model:String},data(){return{isVisible:!1,genderVisible:!1,curType:null,gender:"male"}},computed:{...(0,A.rn)(["activeHorse","currencyType"]),isActive(){return this.active},useCash(){return this.currencyType<1||this.currencyType>1},useGold(){return this.currencyType>0}},methods:{showModal(e){this.curType=e,this.genderVisible=!0},hideModal(){this.curType=null,this.isVisible=!1},hideGenderModal(){this.curType=null,this.genderVisible=!1},setGender(e){this.gender=e,this.genderVisible=!1,this.isVisible=!0},loadHorse(){this.activeHorse&&this.$store.dispatch("setSelectedHorse",null),L.post("loadHorse",{horseModel:this.model})},buyHorse(){null!==this.curType&&(this.curType?L.post("BuyHorse",{ModelH:this.model,Cash:this.horse.cashPrice,IsCash:this.curType,gender:this.gender}):L.post("BuyHorse",{ModelH:this.model,Gold:this.horse.goldPrice,IsCash:this.curType,gender:this.gender}))}},components:{ConfirmationModal:Te}};const pt=(0,r.Z)(mt,[["render",ut],["__scopeId","data-v-c1472e84"]]);var vt=pt,gt={name:"TraderMenuItem",props:{horse:Object,index:Number,selected:Number},emits:["iExpanded"],computed:{...(0,A.rn)(["shopName","myHorses","horses","comps","activeHorse"]),isOpen(){return this.index==this.selected}},methods:{Expand(){this.isOpen||this.$emit("iExpanded",this.index)}},components:{TraderMenuColor:vt}};const bt=(0,r.Z)(gt,[["render",Fe],["__scopeId","data-v-d3642360"]]);var _t=bt,ft={name:"TraderMenu",data(){return{activeDropdown:-1}},methods:{onChildExpansion(e){this.activeDropdown=e}},components:{TraderMenuItem:_t},computed:(0,A.rn)(["horses"])};const Ct=(0,r.Z)(ft,[["render",Ye]]);var yt=Ct;function wt(e,t,s,o,a,l){const n=(0,i.up)("TackShopMenuItem"),r=(0,i.up)("TackShopCostDisplay");return(0,i.wg)(),(0,i.iD)(i.HY,null,[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(e.comps,((e,t)=>((0,i.wg)(),(0,i.j4)(n,{label:t,maxItems:Object.keys(e).length,horseComps:e,key:t},null,8,["label","maxItems","horseComps"])))),128)),(0,i.Wm)(r,{visible:e.showTackPrice,title:"Tack Price"},null,8,["visible"])],64)}const St=e=>((0,i.dD)("data-v-643716bc"),e=e(),(0,i.Cn)(),e),Mt={class:"tackshop"},kt={class:"col s12 panel-cust mb"},xt={class:"col s6 item-cust"},Tt={class:"grey-text-cust title"},Pt={class:"col s6 flex justify-end"},Ht=St((()=>(0,i._)("i",{class:"fas fa-chevron-left"},null,-1))),Et=[Ht],It={class:"item-count flex-none"},Ot={class:"grey-text-count title"},Dt=St((()=>(0,i._)("i",{class:"fas fa-chevron-right"},null,-1))),Gt=[Dt];function $t(e,t,s,o,a,l){return(0,i.wg)(),(0,i.iD)("div",Mt,[(0,i._)("div",kt,[(0,i._)("div",xt,[(0,i._)("h6",Tt,(0,u.zw)(s.label),1)]),(0,i._)("div",Pt,[(0,i._)("button",{class:"button-left btn flex-",onClick:t[0]||(t[0]=e=>l.decrease())},Et),(0,i._)("div",It,[(0,i._)("h6",Ot,(0,u.zw)(l.counter),1)]),(0,i._)("button",{class:"button-right btn flex-none",onClick:t[1]||(t[1]=e=>l.increase())},Gt)])])])}var Rt={name:"TackShopMenuItem",props:{label:{type:String,required:!0},maxItems:{type:Number,required:!0},horseComps:{type:Object,required:!0}},data(){return{curItem:0}},mounted(){let e=JSON.parse(this.activeHorse["components"]);for(const[t,s]of Object.entries(this.horseComps))if(Object.keys(e).length&&e.includes(s["hash"])){this.curItem=parseInt(t)+1;break}this.updateItem()},computed:{...(0,A.rn)(["comps","activeHorse","compCashPrice","compGoldPrice","showTackPrice","allowSave"]),counter(){return`${this.curItem}/${this.maxItems}`}},watch:{curItem(e,t){let s=t-1,o=e-1;s>-1&&!this.isOwned(s)&&(this.$store.dispatch("setCompCashPrice",this.compCashPrice-parseInt(this.horseComps[s]["cashPrice"])),this.$store.dispatch("setCompGoldPrice",this.compGoldPrice-parseInt(this.horseComps[s]["goldPrice"]))),o>-1&&!this.isOwned(o)&&(this.$store.dispatch("setCompCashPrice",this.compCashPrice+parseInt(this.horseComps[o]["cashPrice"])),this.$store.dispatch("setCompGoldPrice",this.compGoldPrice+parseInt(this.horseComps[o]["goldPrice"]))),this.showTackPrice&&0==this.compCashPrice&&0==this.compGoldPrice?this.$store.dispatch("setShowTackPrice",!1):!this.showTackPrice&&this.compCashPrice&&this.compGoldPrice&&(this.$store.dispatch("setShowTackPrice",!0),this.$store.dispatch("setAllowSave",!0))}},methods:{isOwned(e){let t=JSON.parse(this.activeHorse["components"]);return Object.keys(t).length&&t.includes(this.horseComps[e]["hash"])},increase(){++this.curItem>this.maxItems&&(this.curItem=0),this.updateItem()},decrease(){--this.curItem<0&&(this.curItem=this.maxItems),this.updateItem()},updateItem(){L.post(this.label.replace(/\s+/g,""),{id:this.curItem-1,hash:this.curItem-1==-1?"":this.horseComps[this.curItem-1]["hash"]}).catch((e=>{console.log(e.message)}))}}};const Nt=(0,r.Z)(Rt,[["render",$t],["__scopeId","data-v-643716bc"]]);var jt=Nt;const At=e=>((0,i.dD)("data-v-ee4ec3ae"),e=e(),(0,i.Cn)(),e),Wt={key:0,class:"modal-wrapper"},zt={class:"modal"},qt={class:"modal-header"},Lt={class:"modal-body"},Zt={class:"flex cta-wrapper"},Ut=At((()=>(0,i._)("img",{src:"img/money.png"},null,-1))),Yt=At((()=>(0,i._)("img",{src:"img/gold.png"},null,-1)));function Vt(e,t,s,o,a,l){return s.visible?((0,i.wg)(),(0,i.iD)("div",Wt,[(0,i._)("div",zt,[(0,i._)("div",qt,[(0,i._)("span",null,(0,u.zw)(s.title),1)]),(0,i._)("div",Lt,[(0,i._)("div",Zt,[(0,i._)("button",{onClick:t[0]||(t[0]=(...t)=>e.buyWithCash&&e.buyWithCash(...t)),class:"modal-btn flex flex-auto"},[Ut,(0,i.Uk)((0,u.zw)(e.compCashPrice),1)]),(0,i._)("button",{onClick:t[1]||(t[1]=(...t)=>e.buyWithGold&&e.buyWithGold(...t)),class:"modal-btn flex flex-auto"},[Yt,(0,i.Uk)((0,u.zw)(e.compGoldPrice),1)])])])])])):(0,i.kq)("",!0)}var Bt={name:"TackShopCostDisplay",props:{visible:{type:Boolean,required:!0},title:{type:String,default:"Modal Title"}},methods:{close(){this.$emit("update:visible",!1)}},computed:{...(0,A.rn)(["compCashPrice","compGoldPrice"]),isActive(){return this.label==this.selectedPage}}};const Kt=(0,r.Z)(Bt,[["render",Vt],["__scopeId","data-v-ee4ec3ae"]]);var Jt=Kt,Ft={name:"TackShopMenu",props:{},components:{TackShopMenuItem:jt,TackShopCostDisplay:Jt},methods:{},computed:{...(0,A.rn)(["comps","compCashPrice","compGoldPrice","showTackPrice","allowSave"])},beforeUnmount(){this.$store.dispatch("setCompCashPrice",0),this.$store.dispatch("setCompGoldPrice",0),this.$store.dispatch("setShowTackPrice",!1),this.$emit("toggleSave",!1)}};const Qt=(0,r.Z)(Ft,[["render",wt]]);var Xt=Qt,es={name:"HorseMenu",data(){return{page:"Stable",showModal:!1,isRotating:!1,rotateTimer:null}},components:{MenuButton:V,MyStableMenu:Ue,TraderMenu:yt,TackShopMenu:Xt,ConfirmationModal:Te},mounted(){window.addEventListener("mouseup",this.mouseUp,!1)},unmounted(){window.removeEventListener("mouseup",this.mouseUp)},methods:{hideModal(){this.showModal=!1,this.$store.dispatch("setShowTackPrice",!0)},save(){0!=this.compCashPrice||0!=this.compGoldPrice?(this.$store.dispatch("setShowTackPrice",!1),this.showModal=!0):this.purchase(0)},purchase(e){L.post("CloseStable",{MenuAction:"save",cashPrice:this.compCashPrice,goldPrice:this.compGoldPrice,currencyType:e}).catch((e=>{console.log(e.message)}))},close(){L.post("CloseStable",{MenuAction:"Close"}).catch((e=>{console.log(e.message)}))},mouseUp(){this.isRotating=!1,this.stopRotate()},onMouseLeave(){this.stopRotate()},startRotate(e){this.rotate(e),this.isRotating=!0},stopRotate(){null!==this.rotateTimer&&(clearTimeout(this.rotateTimer),this.rotateTimer=null)},rotate(e){L.post("rotate",{RotateHorse:e}),this.rotateTimer=setTimeout((()=>{this.rotate(e)}),15)}},computed:{...(0,A.rn)(["shopName","activeHorse","compCashPrice","compGoldPrice","allowSave"]),isClosed(){return null===this.activeHorse},isSaveEnabled(){return this.allowSave}}};const ts=(0,r.Z)(es,[["render",j],["__scopeId","data-v-7287d9d7"]]);var ss=ts;const os=[{path:"/",name:"home",component:ss}],is=(0,h.p7)({history:(0,h.r5)(),routes:os});var as=is,ls=(0,A.MT)({state:{myHorses:null,horses:null,shopName:null,comps:null,activeHorse:null,compCashPrice:0,compGoldPrice:0,showTackPrice:!1,allowSave:!1,currencyType:null},getters:{},mutations:{SET_MY_HORSES(e,t){e.myHorses=t},SET_HORSES(e,t){e.horses=t},SET_SHOP_NAME(e,t){e.shopName=t},SET_COMPONENTS(e,t){e.comps=t},SET_SELECTED_HORSE(e,t){e.activeHorse=t},SET_COMP_CASH_PRICE(e,t){e.compCashPrice=t},SET_COMP_GOLD_PRICE(e,t){e.compGoldPrice=t},SET_SHOW_TACK_PRICE(e,t){e.showTackPrice=t},SET_ALLOW_SAVE(e,t){e.allowSave=t},SET_CURRENCY_TYPE(e,t){e.currencyType=t}},actions:{setMyHorses(e,t){e.commit("SET_MY_HORSES",t)},setHorses(e,t){e.commit("SET_HORSES",t)},setShopName(e,t){e.commit("SET_SHOP_NAME",t)},setComponents(e,t){e.commit("SET_COMPONENTS",t)},setSelectedHorse(e,t){e.commit("SET_SELECTED_HORSE",t)},setCompCashPrice(e,t){e.commit("SET_COMP_CASH_PRICE",t)},setCompGoldPrice(e,t){e.commit("SET_COMP_GOLD_PRICE",t)},setShowTackPrice(e,t){e.commit("SET_SHOW_TACK_PRICE",t)},setAllowSave(e,t){e.commit("SET_ALLOW_SAVE",t)},setCurrencyType(e,t){e.commit("SET_CURRENCY_TYPE",t)}},modules:{}});(0,o.ri)(d).use(ls).use(as).mount("#app")}},t={};function s(o){var i=t[o];if(void 0!==i)return i.exports;var a=t[o]={exports:{}};return e[o](a,a.exports,s),a.exports}s.m=e,function(){var e=[];s.O=function(t,o,i,a){if(!o){var l=1/0;for(d=0;d<e.length;d++){o=e[d][0],i=e[d][1],a=e[d][2];for(var n=!0,r=0;r<o.length;r++)(!1&a||l>=a)&&Object.keys(s.O).every((function(e){return s.O[e](o[r])}))?o.splice(r--,1):(n=!1,a<l&&(l=a));if(n){e.splice(d--,1);var c=i();void 0!==c&&(t=c)}}return t}a=a||0;for(var d=e.length;d>0&&e[d-1][2]>a;d--)e[d]=e[d-1];e[d]=[o,i,a]}}(),function(){s.n=function(e){var t=e&&e.__esModule?function(){return e["default"]}:function(){return e};return s.d(t,{a:t}),t}}(),function(){s.d=function(e,t){for(var o in t)s.o(t,o)&&!s.o(e,o)&&Object.defineProperty(e,o,{enumerable:!0,get:t[o]})}}(),function(){s.g=function(){if("object"===typeof globalThis)return globalThis;try{return this||new Function("return this")()}catch(e){if("object"===typeof window)return window}}()}(),function(){s.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)}}(),function(){var e={143:0};s.O.j=function(t){return 0===e[t]};var t=function(t,o){var i,a,l=o[0],n=o[1],r=o[2],c=0;if(l.some((function(t){return 0!==e[t]}))){for(i in n)s.o(n,i)&&(s.m[i]=n[i]);if(r)var d=r(s)}for(t&&t(o);c<l.length;c++)a=l[c],s.o(e,a)&&e[a]&&e[a][0](),e[a]=0;return s.O(d)},o=self["webpackChunkui"]=self["webpackChunkui"]||[];o.forEach(t.bind(null,0)),o.push=t.bind(null,o.push.bind(o))}();var o=s.O(void 0,[998],(function(){return s(7185)}));o=s.O(o)})();
//# sourceMappingURL=app.d88e73c0.js.map