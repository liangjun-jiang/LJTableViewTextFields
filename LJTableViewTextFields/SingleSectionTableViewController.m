//
//  SingleSectionTableViewController.m
//  LJTableViewTextFields
//
//  Created by Liangjun Jiang on 10/26/12.
//  Copyright (c) 2012 Liangjun Jiang. All rights reserved.
//

//typedef enum {
//    UIKeyboardTypeDefault,                // Default type for the current input method.
//    UIKeyboardTypeASCIICapable,           // Displays a keyboard which can enter ASCII characters, non-ASCII keyboards remain active
//    UIKeyboardTypeNumbersAndPunctuation,  // Numbers and assorted punctuation.
//    UIKeyboardTypeURL,                    // A type optimized for URL entry (shows . / .com prominently).
//    UIKeyboardTypeNumberPad,              // A number pad (0-9). Suitable for PIN entry.
//    UIKeyboardTypePhonePad,               // A phone pad (1-9, *, 0, #, with letters under the numbers).
//    UIKeyboardTypeNamePhonePad,           // A type optimized for entering a person's name or phone number.
//    UIKeyboardTypeEmailAddress,           // A type optimized for multiple email address entry (shows space @ . prominently).
//    
//    UIKeyboardTypeAlphabet = UIKeyboardTypeASCIICapable, // Deprecated
//    
//} UIKeyboardType;

#import "SingleSectionTableViewController.h"
#import "TextFieldTableCell.h"

static NSString *kSectionTitleKey = @"sectionTitleKey";
static NSString *kSourceKey = @"sourceKey";
static NSString *kViewKey = @"viewKey";

@interface SingleSectionTableViewController ()<UITextFieldDelegate> 
@property (nonatomic, retain) NSArray *dataSourceArray;
@property (nonatomic, assign) NSUInteger selectedCellIndex;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, strong) TextFieldTableCell *activeCell;

@end

@implementation SingleSectionTableViewController
@synthesize selectedCellIndex, isEditing, activeCell;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    isEditing = NO;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.dataSourceArray = [NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"First Name", kSectionTitleKey,
                             @"First Name", kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypeNamePhonePad], kViewKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
                             @"Last Name", kSectionTitleKey,
                             @"Last Name", kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypeNamePhonePad], kViewKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
                             @"Home Phone", kSectionTitleKey,
                             @"555-555-5555", kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypePhonePad], kViewKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
                             @"Work Phone", kSectionTitleKey,
                             @"555-555-5555", kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypePhonePad], kViewKey,
                             nil],
                            
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Email", kSectionTitleKey,
                             @"Email", kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypeEmailAddress], kViewKey,
							 nil],
                            
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Address", kSectionTitleKey,
                             @"Address", kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypeDefault], kViewKey,
							 nil],
                            
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Postal Code", kSectionTitleKey,
                             @"#####", kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypeNumberPad], kViewKey,
							 nil],
                            
							nil];
	
	self.title = NSLocalizedString(@"Customer Info", @"Customer Info");
	
	// we aren't editing any fields yet, it will be in edit when the user touches an edit field
	self.editing = NO;
    
    activeCell = nil;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    selectedCellIndex = 0;
    
    isEditing = editing;
    [self.tableView reloadData];
    
    // we now need to save those data
    if (!editing) {
        isEditing = editing;
        [self.tableView reloadData];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    static NSString *kCellTextField_ID = @"CellTextField_ID";
    
    TextFieldTableCell *cell = (TextFieldTableCell*) [tableView dequeueReusableCellWithIdentifier:kCellTextField_ID];
    
    if (cell == nil)
    {
        // a new cell needs to be created
        cell = [[TextFieldTableCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:kCellTextField_ID] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textField.delegate = self;
    cell.textField.tag = 100 + row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *title = [[self.dataSourceArray objectAtIndex: row] valueForKey:kSectionTitleKey];
    NSString *placeholder = [[self.dataSourceArray objectAtIndex: row] valueForKey:kSourceKey];
    NSNumber *keyboardType = [[self.dataSourceArray objectAtIndex: row] valueForKey:kViewKey];
    [cell setContentForTableCellLabel:title andTextField:placeholder andKeyBoardType:keyboardType andEnabled:isEditing];
    return cell;
}

#pragma mark - Table view delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
   
    // we row this to top
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // the textfield's super view is TextField Cell
    if ([[textField superview] isKindOfClass:[TextFieldTableCell class]]) {
        TextFieldTableCell *cell = (TextFieldTableCell *)[textField superview];
//        activeIndexPath = [self.tableView indexPathForCell:cell];
        activeCell = cell;
    }
    
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0.0, self.view.frame.size.width, 40)];
    keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
    keyboardToolbar.tintColor = [UIColor darkGrayColor];
    
    UIBarButtonItem *prevItem = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleDone target:self action:@selector(onPrev:)];
    
    UIBarButtonItem *spaceItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    spaceItem1.width = 10.0;
    
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(onNext:)];
    
    UIBarButtonItem *spaceItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    spaceItem2.width = 130.0;
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone:)];
    
    NSArray *itemsArray =@[prevItem, spaceItem1, nextItem, spaceItem2, doneItem];
    keyboardToolbar.items = itemsArray;
    
    textField.inputAccessoryView = keyboardToolbar;

    // TODO: CAN I DO BETTER THAN THIS?
    selectedCellIndex = textField.tag;
    return YES;
}

#pragma mark - UITextField Delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}


#pragma mark - IBAction Methods

- (void)onPrev:(id)sender
{
    NSArray *visiableCells = [self.tableView visibleCells];
    [visiableCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TextFieldTableCell *cell = (TextFieldTableCell *)obj;
        if (cell.textField.tag == selectedCellIndex) {
            [cell.textField resignFirstResponder];
        } else if (cell.textField.tag == selectedCellIndex - 1){
            [cell.textField becomeFirstResponder];
            *stop = YES;
        }
        
    }];
    
}

- (void)onNext:(id)sender
{
    NSArray *visiableCells = [self.tableView visibleCells];
    [visiableCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TextFieldTableCell *cell = (TextFieldTableCell *)obj;
        if (cell.textField.tag == selectedCellIndex) {
            [cell.textField resignFirstResponder];
        } else if (cell.textField.tag == selectedCellIndex + 1){
            [cell.textField becomeFirstResponder];
            *stop = YES;
        }
     
    }];
}

- (void)onDone:(id)sender
{
    NSArray *visiableCells = [self.tableView visibleCells];
    [visiableCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TextFieldTableCell *cell = (TextFieldTableCell *)obj;
        if (cell.textField.tag == selectedCellIndex) {
            [cell.textField resignFirstResponder];
        }
        
    }];
    
}

@end
