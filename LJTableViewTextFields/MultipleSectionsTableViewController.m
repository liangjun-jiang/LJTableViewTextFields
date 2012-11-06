//
//  VaTitleTableViewController.m
//  LJTableViewTextFields
//
//  Created by Liangjun Jiang on 10/26/12.
//  Copyright (c) 2012 Liangjun Jiang. All rights reserved.
//

#import "MultipleSectionsTableViewController.h"
#import "TextFieldTableCell.h"

#define TITLE @"title"
#define PLACEHOLDER @"placeholder"

@interface MultipleSectionsViewController ()<UITextViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) NSMutableDictionary *contentList;
@property (nonatomic, assign) NSUInteger selectedCellSection;
@property (nonatomic, assign) NSUInteger selectedCellRow;
@property (nonatomic, strong) NSIndexPath *activeIndexPath;
@property (nonatomic, strong) TextFieldTableCell *activeCell;

@property (nonatomic, strong) NSArray *regionPickerViewArray;

@property (nonatomic, assign) BOOL isEditing;
@end

@implementation MultipleSectionsViewController
@synthesize contentList;
@synthesize selectedCellRow,selectedCellSection;
@synthesize activeIndexPath;
@synthesize isEditing;
@synthesize activeCell, regionPickerViewArray;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"TitleInfo" ofType:@"plist"];
    
    // Make everything mutable
    self.contentList = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:plistPath]
                                                                          options:NSPropertyListMutableContainers
                                                                           format:NULL
                                                                            error:NULL];
    isEditing = NO;
    regionPickerViewArray = @[@"CA",@"FL",@"TX",@"NJ"];
    activeCell = nil;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    isEditing = editing;
    // WE ARE USING SOME HAEVAY WAY
    [self.tableView reloadData];
    // we now need to save those data
    if (!editing) {
        isEditing = NO;
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return [[self.contentList allKeys] objectAtIndex:section];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.contentList allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString *key = [[self.contentList allKeys] objectAtIndex:section];
    return [[self.contentList objectForKey:key] count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    
    UITableViewCell *cell;
    
    static NSString *TextFieldCell1 = @"TextFieldCell1";
    static NSString *TextFieldCell2 = @"TextFieldCell2";
    static NSString *TextFieldCell3 = @"TextFieldCell3";
    
    NSString *key = [[self.contentList allKeys] objectAtIndex:section];
    NSString *title = [[[self.contentList objectForKey:key] objectAtIndex:row] objectForKey:TITLE];
    
    NSString *placeholder = [[[self.contentList objectForKey:key] objectAtIndex:row] objectForKey:PLACEHOLDER];
    
    TextFieldTableCell *temp;
        // the following is necessary to get not messed-up cells
    if (section == 0) {
        temp = (TextFieldTableCell*)[tableView dequeueReusableCellWithIdentifier:TextFieldCell1];
        if (temp == nil) {
            temp = [[TextFieldTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextFieldCell1];
        }
        
    } else if (section == 1){
        temp = (TextFieldTableCell*)[tableView dequeueReusableCellWithIdentifier:TextFieldCell2];
        if (temp == nil) {
            temp = [[TextFieldTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextFieldCell2];
        }
    } else {
        temp = (TextFieldTableCell*)[tableView dequeueReusableCellWithIdentifier:TextFieldCell3];
        if (temp == nil) {
            temp = [[TextFieldTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextFieldCell3];
        }
    }
    temp.textField.tag = (section +1)* 100 + row;
    temp.textField.delegate = self;
    [temp setContentForTableCellLabel:title andTextField:placeholder andKeyBoardType:[NSNumber numberWithInt:1] andEnabled:isEditing];
    cell = temp;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
   
    // we move the current selected cell to top of the tableview
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // the textfield's super view is TextField Cell
    if ([[textField superview] isKindOfClass:[TextFieldTableCell class]]) {
        TextFieldTableCell *cell = (TextFieldTableCell *)[textField superview];
        activeIndexPath = [self.tableView indexPathForCell:cell];
        activeCell = cell;
    }
    
    // should this be an independent class?
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
    
    NSArray *itemsArray =  @[prevItem, spaceItem1, nextItem, spaceItem2, doneItem];
    keyboardToolbar.items = itemsArray;
    textField.inputAccessoryView = keyboardToolbar;
    
    if (textField.tag == 100 || textField.tag == 200 || textField.tag == 201 || textField.tag == 306 ||
        textField.tag == 307 || textField.tag == 312){
        
        UIDatePicker *datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        datePickerView.datePickerMode = UIDatePickerModeDate;
        textField.inputView = datePickerView;
        [datePickerView addTarget:self
                       action:@selector(onDatePicker:)
             forControlEvents:UIControlEventValueChanged];
        
        // this animiation was from Apple Sample Code: DateCell
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		CGSize pickerSize = [datePickerView sizeThatFits:CGSizeZero];
		CGRect startRect = CGRectMake(0.0,
									  screenRect.origin.y + screenRect.size.height,
									  pickerSize.width, pickerSize.height);
		datePickerView.frame = startRect;
		
      	// compute the end frame
		CGRect pickerRect = CGRectMake(0.0,
									   screenRect.origin.y + screenRect.size.height - pickerSize.height,
									   pickerSize.width,
									   pickerSize.height);
        
        datePickerView.frame = pickerRect;

    } else if (textField.tag == 311 || textField.tag == 301)  // the user is going to choose from State/Region list
    
    {
        // cool, I need to create another UIPicker to get the states/regions info
        
        UIPickerView *regionPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        regionPicker.showsSelectionIndicator = YES;	// note this is default to NO
        
        // this view controller is the data source and delegate
        regionPicker.delegate = self;
        regionPicker.dataSource = self;
        
        textField.inputView = regionPicker;
        
        // this animiation was from Apple Sample Code: DateCell
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		CGSize pickerSize = [regionPicker sizeThatFits:CGSizeZero];
		CGRect startRect = CGRectMake(0.0,
									  screenRect.origin.y + screenRect.size.height,
									  pickerSize.width, pickerSize.height);
		regionPicker.frame = startRect;
		
		// compute the end frame
		CGRect pickerRect = CGRectMake(0.0,
									   screenRect.origin.y + screenRect.size.height - pickerSize.height,
									   pickerSize.width,
									   pickerSize.height);
        
        // add some animation if you like
        regionPicker.frame = pickerRect;
    }
  
    
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
    
    [activeCell.textField resignFirstResponder];
    NSUInteger activeCellRow = activeCell.textField.tag % 100;
    NSUInteger activeCellSection = activeCell.textField.tag / 100;
    UITextField *previousTextField;
    if (activeCellRow > 0) {
        
        // WATCH OUT: here will be some issue if the "previousTextField" is not on screen, the keyboard will not show
        
        previousTextField = (UITextField*)[self.tableView viewWithTag:(activeCellSection  * 100 + activeCellRow - 1)];
        [previousTextField becomeFirstResponder];
    } else if (activeCellRow == 0) {
        if (activeCellSection > 1) {
            activeCellSection -=1;
            NSString *key = [[self.contentList allKeys] objectAtIndex:activeCellSection-1]; // we need to get the real section index
            NSUInteger rowCount =  [[self.contentList objectForKey:key] count];
            activeCellRow = rowCount -1;
            previousTextField = (UITextField*)[self.tableView viewWithTag:(activeCellSection * 100 + activeCellRow)];
            [previousTextField becomeFirstResponder];
        }
        
    }
}

- (void)onNext:(id)sender
{
    [activeCell.textField resignFirstResponder];
    
    NSUInteger activeCellRow = activeCell.textField.tag % 100;
    NSUInteger activeCellSection = activeCell.textField.tag / 100;
    NSString *key = [[self.contentList allKeys] objectAtIndex:(activeCellSection-1)];
    NSUInteger rowCount =  [[self.contentList objectForKey:key] count];
    UITextField *nextTextField;
    
    if (activeCellRow <rowCount-1) {
        nextTextField = (UITextField*)[self.tableView viewWithTag:(activeCellSection * 100 + (activeCellRow+1))];
        [nextTextField becomeFirstResponder];
        
    } else if (activeCellRow == rowCount-1) {
        activeCellSection +=1;
        if (activeCellSection <= [[self.contentList allKeys] count] - 1) {
            activeCellRow = 0;
            nextTextField = (UITextField*)[self.tableView viewWithTag:(activeCellSection * 100 + activeCellRow)];
            [nextTextField becomeFirstResponder];
            
        }
    }
 
}

- (void)onDone:(id)sender
{
    NSArray *visiableCells = [self.tableView visibleCells];
    [visiableCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[TextFieldTableCell class]]) {
            TextFieldTableCell *cell = (TextFieldTableCell *)obj;
            [cell.textField resignFirstResponder];
            if (cell.textField.tag == selectedCellRow) {
                [cell.textField resignFirstResponder];
            }
        }
        
    }];
    
}

- (void)onDatePicker:(id)sender
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
   
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    activeCell.textField.text = [NSString stringWithFormat:@"%@",[dateFormat stringFromDate:datePicker.date]];

}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    activeCell.textField.text = [regionPickerViewArray objectAtIndex:row];
}


#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [regionPickerViewArray objectAtIndex:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	CGFloat componentWidth = 280.0;
 	return componentWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [regionPickerViewArray count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

@end
