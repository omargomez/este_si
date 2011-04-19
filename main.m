#import <UIKit/UIKit.h>

@interface HelloController : UITableViewController 
{
	NSMutableArray *sectionArray;
	int fullCount;
}
@end

@implementation HelloController
#define ALPHA @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"

// Initialize the table view controller with the grouped style
- (HelloController *) init
{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) self.title = @"Crayon Colors";
	return self;
}

// One section for each alphabet member
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return [sectionArray count];
}

// Each row array object contains the members for that section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [[sectionArray objectAtIndex:section] count];
}

// Convert a 6-character hex color to a UIColor object
- (UIColor *) getColor: (NSString *) hexColor
{
	unsigned int red, green, blue;
	NSRange range;
	range.length = 2;
	
	range.location = 0; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
	range.location = 2; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
	range.location = 4; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];	
	
	return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:1.0f];
}

// Return a cell for the ith row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];

	// Create a cell if one is not already available
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil) 
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"any-cell"] autorelease];

	// Set up the cell by coloring its text
	NSArray *crayon = [[[sectionArray objectAtIndex:section] objectAtIndex:row] componentsSeparatedByString:@"#"];
	cell.text = [crayon objectAtIndex:0];
	cell.textColor = [self getColor:[crayon objectAtIndex:1]];
	
	return cell;
}

// Remove the current table row selection
- (void) deselect
{	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

// Respond to user selection by coloring the navigation bar
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath
{
	// Retrieve named color
	int row = [newIndexPath row];
	int section = [newIndexPath section];
	NSArray *crayon = [[[sectionArray objectAtIndex:section] objectAtIndex:row] componentsSeparatedByString:@"#"];
	
	// Update the nav bar color
	self.navigationController.navigationBar.tintColor = [self getColor:[crayon objectAtIndex:1]];
	
	// Deselect
	[self performSelector:@selector(deselect) withObject:NULL afterDelay:0.5];
}

// Build a section/row list from the alphabetically ordered word list
- (void) createSectionList: (id) wordArray
{
	// Build an array with 26 sub-array sections
	sectionArray = [[[NSMutableArray alloc] init] retain];
	for (int i = 0; i < 26; i++) [sectionArray addObject:[[[NSMutableArray alloc] init] retain]];
	
	// Add each word to its alphabetical section
	for (NSString *word in wordArray)
	{
		if ([word length] == 0) continue;
		
		// determine which letter starts the name
		NSRange range = [ALPHA rangeOfString:[[word substringToIndex:1] uppercaseString]];
		
		// Add the name to the proper array
		[[sectionArray objectAtIndex:range.location] addObject:word];
	}
}

// Prepare the Table View
- (void)loadView
{
	[super loadView];
	
	// Retrieve the text and colors from file
	NSString *pathname = [[NSBundle mainBundle]  pathForResource:@"crayons" ofType:@"txt" inDirectory:@"/"];
	NSString *wordstring = [NSString stringWithContentsOfFile:pathname];
    NSArray *wordArray = [[wordstring componentsSeparatedByString:@"\n"] retain];
	
	// Build the sorted section array
    [self createSectionList:wordArray];
}

// Clean up
-(void) dealloc
{
	[sectionArray release];
	[super dealloc];
}
@end


@interface SampleAppDelegate : NSObject <UIApplicationDelegate> 
{
	UINavigationController *nav;
}
@property (nonatomic, retain)		UINavigationController *nav;
@end

@implementation SampleAppDelegate
@synthesize nav;
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.nav = [[UINavigationController alloc] initWithRootViewController:[[HelloController alloc] init]];
	[window addSubview:self.nav.view];
	[window makeKeyAndVisible];
}

- (void) dealloc
{
	[self.nav release];
	[super dealloc];
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"SampleAppDelegate");
	[pool release];
	return retVal;
}
