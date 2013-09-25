IPaUITool
=========

UI Tools I use a lot

IPaAlertView
=============
Block-base AlertView for IOS

you can easily use class method

+(id)IPaAlertViewWithTitle:(NSString*)title message:(NSString*)message 
                    callback:(void (^)(NSInteger))callback
           cancelButtonTitles:(NSString*)cancelButtonTitle ,...NS_REQUIRES_NIL_TERMINATION;

to show a UIAlertView (if you use class method,you don't need to make [UIAlertView show],it will automatically to do that)

callback block has one parameter, it is button index on UIAlertView


IPaActionSheet
=============
block-base Action Sheet


IPaPTRTableViewController
=============
custom pull to reload TableViewController


IPaListSrollView
================

IPaListScrollView is a scroll view that can display list items

every item has to be the same size (and the same format)

it can display column major or row major

it will only create items that need to presented on the screen

ex: when you need to show 100 UIView in the scroll view

but there will only a maximum of 10 will be display on screen at the same time

then it will create only 10 items



in IOS 6 there is UICollectionView

that is powerful than IPaListScrollView

but UICollectionView can not do Loop mode



it starts to create items when you set controlDelegate

after that you need to do [IPaListSrollView ReloadContent] when your item number change

or data of item is modified, or it will not update UIView that is already presented


when you need to change IPaListScrollView Size

you need to do [IPaListScrollView RefreshItemViews] because it need to recompute the item number it needs,and recreate

(or release) items

IPaPDFView
==========

base on IPaListScrollView

will upgrade to UICollectionView in the future….



IPaPageControlTableViewController
==========
UITableViewController that manage your data with page
the lowest cell will be loading cell
when it shows up, IPaPageControlTableViewController will call
-(void)loadDataWithPage:(NSUInteger)page callback:(void (^)(NSArray*,NSUInteger))callback;
to download  next page,make sure you do callback in this function

