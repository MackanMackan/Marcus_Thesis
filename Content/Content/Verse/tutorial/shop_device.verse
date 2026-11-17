
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }


shop_device := class(creative_device):

    @editable ShopButton:conditional_button_device = conditional_button_device{}
    @editable ItemGranter:item_granter_device = item_granter_device{}
    @editable ItemCost : int = 100
 
    GoldKeyIndex:int = 0
 
    OnBegin<override>()<suspends>:void =
        ShopButton.SetItemCountRequired(GoldKeyIndex, ItemCost)
        ShopButton.ActivatedEvent.Subscribe(OnBought)
        ShopButton.NotEnoughItemsEvent.Subscribe(OnNotEnoughGold)

    OnBought(Agent:agent):void =
        ItemGranter.GrantItem(Agent)
        Print("Item bought")
 
    OnNotEnoughGold(Agent:agent):void =
        Gold := GetGold(Agent)
        Price := ShopButton.GetItemCountRequired(GoldKeyIndex)
        Print("Not enough gold: has {Gold}, needs {Price}")

    GetGold(Agent:agent):int =
        ShopButton.GetItemCount(Agent, GoldKeyIndex)