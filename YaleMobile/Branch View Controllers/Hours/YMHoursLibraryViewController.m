//
//  YMHoursLibraryViewController.m
//  YaleMobile
//
//  Created by Danqing on 6/22/13.
//  Copyright (c) 2013 Danqing Liu. All rights reserved.
//

#import "YMHoursLibraryViewController.h"
#import "YMGlobalHelper.h"
#import "YMServerCommunicator.h"
#import "YMSubtitleCell.h"

#import "YMTheme.h"

@interface YMHoursLibraryViewController ()

@end

@implementation YMHoursLibraryViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
   UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [self.data objectForKey:@"code"]]]];
   backgroundView.contentMode = UIViewContentModeScaleToFill;
   [backgroundView setFrame:self.view.frame];
   [self.view addSubview:backgroundView];
   [self.view sendSubviewToBack:backgroundView];
  
  self.tableView1.backgroundColor = [UIColor clearColor];
  self.tableView1.showsVerticalScrollIndicator = NO;
  [self updateTableHeader];

  
  UIView *footerPlaceholder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
  footerPlaceholder.backgroundColor = [UIColor clearColor];
  self.tableView1.tableFooterView = footerPlaceholder;
  
  float height = ([[UIScreen mainScreen] bounds].size.height == 568) ? 568 : 480;
  UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, height)];
  view.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_overlay.png", [self.data objectForKey:@"code"]]];
  view.contentMode = UIViewContentModeScaleToFill;
  [self.view insertSubview:view belowSubview:self.tableView1];
  self.overlay = view;
  view.alpha = 0;
  
  [YMServerCommunicator getLibraryHoursForLocation:[self.data objectForKey:@"code"] controller:self usingBlock:^(NSArray *hour) {
    self.hour = [self parseJSONArray:hour];
    [self.tableView1 reloadData];
  }];
 
  self.tableView1.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  self.navigationController.navigationBar.translucent = YES;
  self.navigationController.navigationBar.alpha = 0.7;
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  [YMServerCommunicator cancelAllHTTPRequests];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)back:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
  UIView *cell = [gestureRecognizer view];
  CGPoint translation = [gestureRecognizer translationInView:[cell superview]];
  if (fabsf(translation.x) > fabsf(translation.y)) return YES;
  return NO;
}

- (NSString *)parseJSONArray:(NSArray *)array
{
  NSMutableArray *components = [[NSMutableArray alloc] init];
  for (NSDictionary *entry in array) {
    [components addObject:[NSString stringWithFormat:@"%@\n •  ", [entry objectForKey:@"name"]]];
    if ([[[entry objectForKey:@"times"] objectForKey:@"status"] isEqualToString:@"open"]) {
      NSArray *hours = [[entry objectForKey:@"times"] objectForKey:@"hours"];
      for (NSUInteger j = 0; j < hours.count; j++) {
        NSDictionary *detail = [hours objectAtIndex:j];
        [components addObject:[NSString stringWithFormat:@"%@ - %@", [detail objectForKey:@"from"], [detail objectForKey:@"to"]]];
        (j == hours.count - 1) ? [components addObject:@"\n"] : [components addObject:@", "];
      }
    } else [components addObject:@"Closed\n"];
  }
  return [components componentsJoinedByString:@""];
}

- (void)updateTableHeader
{
  float extra = ([[UIScreen mainScreen] bounds].size.height == 568) ? 316 : 228;
  
  UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 140 + extra, 286, 28)];
  headerLabel.text = self.name;
  headerLabel.textColor = [UIColor whiteColor];
  headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
  headerLabel.backgroundColor = [UIColor clearColor];
  headerLabel.numberOfLines = 0;
  
  /* deprecated code
   CGSize textSize = [self.name sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18] constrainedToSize:CGSizeMake(286.0, 3000)];
   */
  CGSize textSize = [YMGlobalHelper boundText:self.name withFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18] andConstraintSize:CGSizeMake(286.0, 3000)];
  CGRect newFrame = headerLabel.frame;
  newFrame.size.height = textSize.height;
  headerLabel.frame = newFrame;
  
  UILabel *headerSublabel = [[UILabel alloc] initWithFrame:CGRectMake(24, headerLabel.frame.size.height + extra + 140, 286, 25)];
  headerSublabel.textColor = [UIColor whiteColor];
  headerSublabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
  headerSublabel.backgroundColor = [UIColor clearColor];
  headerSublabel.numberOfLines = 0;
  headerSublabel.text = [self.data objectForKey:@"address"];
  
  CGSize textSize2 = [[self.data objectForKey:@"address"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] constrainedToSize:CGSizeMake(286.0, 3000)];
  CGRect newFrame2 = headerSublabel.frame;
  newFrame2.size.height = textSize2.height;
  headerSublabel.frame = newFrame2;
  
  UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 150 + headerLabel.frame.size.height + headerSublabel.frame.size.height + extra)];
  
  [containerView addSubview:headerLabel];
  [containerView addSubview:headerSublabel];
  
  self.tableView1.tableHeaderView = containerView;
  [self.tableView1 reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  CGFloat offset = scrollView.contentOffset.y;
  self.overlay.alpha = offset/400;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
  switch (result) {
    case MFMailComposeResultCancelled:
      DLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
      break;
    case MFMailComposeResultSaved:
      DLog(@"Mail saved: you saved the email message in the drafts folder.");
      break;
    case MFMailComposeResultSent:
      DLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
      break;
    case MFMailComposeResultFailed:
      DLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
      break;
    default:
      DLog(@"Mail not sent.");
      break;
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createActionSheetWithNumber:(NSString *)number
{
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Do you want to call %@?", number] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"Call %@", number], @"Copy to Clipboard", nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
  [actionSheet showInView:self.view];
}

- (void)createActionSheetWithString:(NSString *)string
{
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy to Clipboard", nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
  [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex != [actionSheet cancelButtonIndex]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.phoneURL]];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  cell.backgroundColor = [UIColor clearColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  YMSubtitleCell *cell;
  
  if (indexPath.row == 0) cell = (YMSubtitleCell *)[tableView dequeueReusableCellWithIdentifier:@"Hours Library Cell 1"];
  else cell = (YMSubtitleCell *)[tableView dequeueReusableCellWithIdentifier:@"Hours Library Cell 2"];
  cell.userInteractionEnabled = NO;
  
  if (indexPath.row == 0) {
    cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"dtablebg_top.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 5, 20)]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tablebg_top_highlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 5, 20)]];
    cell.secondary1.text = @"Today's Hours";
    cell.primary1.text = self.hour;
    /* deprecated code
     CGSize textSize = [self.hour sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15] constrainedToSize:CGSizeMake(268, 5000)];
     */
    CGSize textSize = [YMGlobalHelper boundText:self.hour withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15] andConstraintSize:CGSizeMake(268, 5000)];
    CGRect frame = cell.primary1.frame;
    frame.size.height = textSize.height;
  } else if (indexPath.row == 3) {
    cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"dtablebg_bottom.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 20, 10, 20)]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tablebg_bottom_highlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 20, 10, 20)]];
    cell.secondary1.text = @"Contact Email";
    cell.primary1.text = [self.data objectForKey:@"email"];
    cell.userInteractionEnabled = YES;
  } else {
    cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"dtablebg_mid.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 20, 10, 20)]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tablebg_mid_highlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 20, 10, 20)]];
    if (indexPath.row == 2) {
      cell.secondary1.text = @"Contact Number";
      cell.primary1.text = [self.data objectForKey:@"phone"];
      cell.userInteractionEnabled = YES;
    } else {
      cell.secondary1.text = @"Access Information";
      NSString *text = [self.data objectForKey:@"access"];
      /* deprecated
      CGSize textSize = [text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15] constrainedToSize:CGSizeMake(268, 5000)];
       */
      CGSize textSize = [YMGlobalHelper boundText:text withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15] andConstraintSize:CGSizeMake(268, 5000)];
      CGRect frame = cell.primary1.frame;
      frame.size.height = textSize.height;
      cell.primary1.text = text;
    }
  }
  
  cell.primary1.textColor   = [YMTheme white];
  cell.primary1.highlightedTextColor = cell.primary1.textColor;
  cell.secondary1.textColor = [YMTheme white];
  cell.secondary1.highlightedTextColor = cell.secondary1.textColor;
  
//  [YMGlobalHelper setupHighlightBackgroundViewWithColor:[YMTheme cellHighlightBackgroundViewColor]
//                                                forCell:cell];
  
  cell.backgroundView.alpha = 0.4;
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 3)
    return 71;
  else if (indexPath.row == 2)
    return 61;
  else if (indexPath.row == 0) {
    /* deprecated
    CGSize textSize = [self.hour sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15] constrainedToSize:CGSizeMake(268, 5000)];
     */
    CGSize textSize = [YMGlobalHelper boundText:self.hour withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15] andConstraintSize:CGSizeMake(268, 5000)];
    return textSize.height + 50;
  } else {
    NSString *text = [self.data objectForKey:@"access"];
    /* deprecated
    CGSize textSize = [text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15] constrainedToSize:CGSizeMake(268, 5000)];
     */
    CGSize textSize = [YMGlobalHelper boundText:text withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15] andConstraintSize:CGSizeMake(268, 5000)];
    return textSize.height + 40;
  }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self.tableView1 deselectRowAtIndexPath:indexPath animated:YES];
  YMSubtitleCell *cell = (YMSubtitleCell *)[tableView cellForRowAtIndexPath:indexPath];
  if ([cell.secondary1.text isEqualToString:@"Contact Email"]) {
    if ([MFMailComposeViewController canSendMail]) {
      MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
      mailer.mailComposeDelegate = self;
      NSArray *toRecipients = [NSArray arrayWithObjects:cell.primary1.text, nil];
      [mailer setToRecipients:toRecipients];
      [[mailer navigationBar] setTintColor:[UIColor whiteColor]];
      [self presentViewController:mailer animated:YES completion:nil];
    } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"YaleMobile is unable to launch the email service. Your device doesn't support the composer sheet."
                                                     delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
    }
  }
  if ([cell.secondary1.text isEqualToString:@"Contact Number"]) {
    NSString *phoneNo = cell.primary1.text;
    self.phoneURL = [@"tel://" stringByAppendingString:phoneNo];
    [self createActionSheetWithNumber:phoneNo];
  }
}

@end
