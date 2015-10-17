//
//  WeatherForecastTableViewController.m
//  unit-2-assessment
//
//  Created by Justine Gartner 🙏🏼 on 10/17/15.
//  Copyright © 2015 Michael Kavouras. All rights reserved.
//

//22.9068° S, 43.1729° W Rio De Janeiro
//40.6928° N, 73.9903° W Brooklyn
//64.1333° N, 21.9333° W Reykjevik, Iceland
//11.9310° N, 79.7852° E Pondicherry, India

#define ForecastAPIKey @"https://api.forecast.io/forecast/8040fc5b15adaaafabbe7de9c3ff5458/"

#import <AFNetworking/AFNetworking.h>
#import "WeatherForecastTableViewController.h"
#import "ForecastDetailViewController.h"
#import "APIManager.h"
#import "WeatherForecastResult.h"
#import "ForecastTableViewCell.h"
#import "Location.h"

@interface WeatherForecastTableViewController ()

@property (nonatomic) NSMutableArray *forecasts;
@property (nonatomic) Location *location;

@end

@implementation WeatherForecastTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = nil;
    
}

- (void) viewWillAppear:(BOOL)animated{
    
    [self setUpCustomTableViewCells];
    
    self.location = [[Location alloc]init];
    [self.location loadUserLocation];
    
    NSLog(@"latitude: %ld, longitude: %ld", self.location.latitude, self.location.longitude);
    
    [self GETWeatherForecastsWithLatitude:self.location.latitude AndLongitude:self.location.longitude];
    
    [self.tableView reloadData];
}

-(void)setUpCustomTableViewCells{

    UINib *nib = [UINib nibWithNibName:@"ForecastTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ForecastCellIdentifier"];
}


-(void)GETWeatherForecastsWithLatitude: (NSInteger)latitude AndLongitude: (NSInteger)longitude{
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@%ld,%ld", ForecastAPIKey, latitude, longitude];
    
    NSLog(@"urlString: %@",urlString);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlString parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        self.forecasts = [[NSMutableArray alloc]init];
        
        NSArray *searchResults = responseObject[@"daily"][@"data"];
        

        for (NSDictionary *result in searchResults){
            
            WeatherForecastResult *forecast = [[WeatherForecastResult alloc] initWithJSON:result];
            
            [self.forecasts addObject:forecast];
            
        }
        
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];

}

#pragma mark - Table View delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSegueWithIdentifier:@"ForecastDetailViewController" sender:self];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.forecasts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ForecastTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ForecastCellIdentifier" forIndexPath:indexPath];
    
    WeatherForecastResult *forecast = self.forecasts[indexPath.row];
    
    NSString *dayOfWeek = [APIManager dayOfWeekFromTimestamp:forecast.dayOfWeek];
    cell.dayOfWeekLabel.text = dayOfWeek;
    
    cell.tempLabel.text = [NSString stringWithFormat:@"Low: %ld, High: %ld",forecast.tempMin, forecast.tempMax];
    cell.iconImageVIew.image = [UIImage imageNamed:forecast.imageName];
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ForecastDetailViewController"]) {
    
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        ForecastDetailViewController *forecastDetailVC = segue.destinationViewController;
        
        WeatherForecastResult *forecast = self.forecasts[indexPath.row];
        
        forecastDetailVC.forecast = forecast;
    }
}


@end
