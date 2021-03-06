/*

 Copyright (c) 2013 Joan Lluch <joan.lluch@sweetwilliamsl.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

*/

#import "RearViewController.h"

#import "SWRevealViewController.h"
#import "FrontViewController.h"
#import "MapViewController.h"

@interface RearViewController()

@end

@implementation RearViewController

@synthesize rearTableView = _rearTableView;

/*
 * The following lines are crucial to understanding how the SWRevealController works.
 *
 * In this example, we show how a SWRevealController can be contained in another instance 
 * of the same class. We have three scenarios of hierarchies as follows
 *
 * In the first scenario a FrontViewController is contained inside of a UINavigationController.
 * And the UINavigationController is contained inside of a SWRevealController. Thus the
 * following hierarchy is created:
 *
 * - SWRevealController is parent of:
 * - - UINavigationController is parent of:
 * - - - FrontViewController
 *
 * In the second scenario a MapViewController is contained inside of a UINavigationController.
 * And the UINavigationController is contained inside of a SWRevealController. Thus the
 * following hierarchy is created:
 *
 * - SWRevealController is parent of:
 * - - UINavigationController is parent of:
 * - - - MapViewController
 *
 * In the third scenario a SWRevealViewController is contained directly inside of another.
 * SWRevealController. The second SWRevealController can in turn contain anything.
 * contain any of the above Thus the
 * following hierarchy is created:
 *
 * - SWRevealController is parent of:
 * - - SWRevealController
 *
 * If you set ShouldContainRevealControllerInNavigator to true, a UINavigationController will be used to
 * contain child SWRevealControllers, thus producing a vertical cascade effect on the user interface
 */

#define ShouldContainRevealControllerInNavigator false

- (void)viewDidLoad
{
	[super viewDidLoad];
	
    // We determine whether we have a grand parent SWRevealViewController, this means we are at least one level behind the hierarchy
    SWRevealViewController *parentRevealController = self.revealViewController;
    SWRevealViewController *grandParentRevealController = parentRevealController.revealViewController;
    
    UIBarButtonItem *titleButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:0];
    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:0];
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
            style:UIBarButtonItemStyleBordered target:grandParentRevealController action:@selector(revealToggle:)];
    
    // if we have a reveal controller as a grand parent, this means we are are being added as a
    // child of a detail (child) reveal controller, so we add a gesture recognizer provided by our grand parent to our
    // toolbar as well as a "reveal" button
    if ( grandParentRevealController )
    {
        // to present a title, we count the number of ancestor reveal controllers we have, this is of course
        // only a hack for demonstration purposes, on a real project you would have a model telling this.
        NSInteger level=0;
        UIViewController *controller = grandParentRevealController;
        while( nil != (controller = [controller revealViewController]) )
            level++;
        
        NSString *title = [NSString stringWithFormat:@"Detail Level %d", level];
        
        // if our parent reveal controller was contained in a navigation controller we set the title, gesture, and button
        // on its navigation bar
        if ([parentRevealController navigationController])
        {
            [parentRevealController.navigationController.navigationBar addGestureRecognizer:grandParentRevealController.panGestureRecognizer];
            parentRevealController.navigationItem.leftBarButtonItem = revealButtonItem;
            parentRevealController.navigationItem.title = title;
        }
        
        // otherwise, our reveal controller was directly inserted in the hierarchy so we use our toolbar to set the
        // controls
        else
        {
            [_rearToolBar addGestureRecognizer:grandParentRevealController.panGestureRecognizer];
            [titleButtonItem setTitle:title];
            [_rearToolBar setItems:@[revealButtonItem,spaceButtonItem,titleButtonItem,spaceButtonItem]];
        }
    }
    
    // otherwise, we are in the top reveal controller, so we just add a title
    else
    {
        [titleButtonItem setTitle:@"Master"];
        [_rearToolBar setItems:@[spaceButtonItem,titleButtonItem,spaceButtonItem]];
    }
}



#pragma marl - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	NSInteger row = indexPath.row;
    
	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
	}
	
	if (row == 0)
	{
		cell.textLabel.text = @"Front View Controller";
	}
	else if (row == 1)
	{
		cell.textLabel.text = @"Map View Controller";
	}
	else if (row == 2)
	{
		cell.textLabel.text = @"Enter Presentation Mode";
	}
	else if (row == 3)
	{
		cell.textLabel.text = @"Resign Presentation Mode";
	}
    
    else if (row == 4)
	{
		cell.textLabel.text = @"A RevealViewController !!";
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Grab a handle to the reveal controller, as if you'd do with a navigtion controller via self.navigationController.
    SWRevealViewController *revealController = [self revealViewController];
    UIViewController *frontViewController = revealController.frontViewController;
    UINavigationController *frontNavigationController =nil;
    
    if ( [frontViewController isKindOfClass:[UINavigationController class]] )
        frontNavigationController = (id)frontViewController;
    
    
    NSInteger row = indexPath.row;

	// Here you'd implement some of your own logic... I simply take for granted that the first row (=0) corresponds to the "FrontViewController".
	if (row == 0)
	{
		// Now let's see if we're not attempting to swap the current frontViewController for a new instance of ITSELF, which'd be highly redundant.        
        if ( ![frontNavigationController.topViewController isKindOfClass:[FrontViewController class]] )
        {
			FrontViewController *frontViewController = [[FrontViewController alloc] init];
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
			[revealController setFrontViewController:navigationController animated:YES];
        }
		// Seems the user attempts to 'switch' to exactly the same controller he came from!
		else
		{
            [revealController revealToggleAnimated:YES];
		}
	}
    
	// ... and the second row (=1) corresponds to the "MapViewController".
	else if (row == 1)
	{
		// Now let's see if we're not attempting to swap the current frontViewController for a new instance of ITSELF, which'd be highly redundant.
        if ( ![frontNavigationController.topViewController isKindOfClass:[MapViewController class]] )
        {
			MapViewController *mapViewController = [[MapViewController alloc] init];
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
			[revealController setFrontViewController:navigationController animated:YES];
		}
        
		// Seems the user attempts to 'switch' to exactly the same controller he came from!
		else
		{
            [revealController revealToggleAnimated:YES];
		}
	}
	else if (row == 2)
	{
        [revealController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
	}
	else if (row == 3)
	{
        [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
	}
    
    else if (row == 4)
	{
        if ( ![frontViewController isKindOfClass:[SWRevealViewController class]] &&
            ![frontNavigationController.topViewController isKindOfClass:[SWRevealViewController class]])
        {
            FrontViewController *frontViewController = [[FrontViewController alloc] init];
            RearViewController *rearViewController = [[RearViewController alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
            SWRevealViewController *childRevealController = [[SWRevealViewController alloc]
                initWithRearViewController:rearViewController frontViewController:navigationController];
            
            [childRevealController setFrontViewPosition:FrontViewPositionRight animated:NO];
            
#if ShouldContainRevealControllerInNavigator == false
            [revealController setFrontViewController:childRevealController animated:YES];
#else
            UINavigationController *revealNavController = [[UINavigationController alloc] initWithRootViewController:childRevealController];
            [revealController setFrontViewController:revealNavController animated:YES];
#endif
        }
        else
        {
            [revealController revealToggleAnimated:YES];
        }
	}
}



@end