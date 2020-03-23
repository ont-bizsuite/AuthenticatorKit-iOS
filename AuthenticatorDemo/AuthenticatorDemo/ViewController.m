//
//  ViewController.m
//  AuthenticatorDemo
//
//  Created by Mac on 2019/11/11.
//  Copyright © 2019 Onchain. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

typedef NS_ENUM(NSUInteger, ActionType) {
    ActionTypeDecentralizedRegister         = 0, // Decentralized registration（去中心化的注册【需要调起 ONTAuth】）
    ActionTypeDecentralizedLogin            = 1, // Decentralized login（去中心化的登录【需要调起 ONTAuth】）
    ActionTypeApplyClaim                    = 2, // Apply Claim（申请 Claim）
    ActionTypeGetClaim                      = 3, // Get Claim（获取 Claim（需要先申请 Claim）【需要调起 ONTAuth】）
    ActionTypeAuthorizeClaim                = 4, // Authorize Claim（授权 Claim【需要调起 ONTAuth】）
    ActionTypeCentralizedRegister           = 5, // Centralized registration（中心化的注册）
    ActionTypeCentralizedLogin              = 6, // Centralized login（中心化的登录）
    ActionTypeCentralizedAddOwner           = 7, // Centralized add Owner（中心化的添加 Owner【需要调起 ONTAuth】）
    ActionTypeCentralizedLoginByOwner       = 8, // Centralized login by Owner（中心化的通过 Owner 登录【需要调起 ONTAuth】）
};


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *decentralizedRegisterOntid;
@property (nonatomic, strong) NSString *decentralizedLoginOntid;

@property (nonatomic, strong) NSString *centralizedRegisterUsername;
@property (nonatomic, strong) NSString *centralizedRegisterPassword;
@property (nonatomic, strong) NSString *centralizedRegisterOntid;

@property (nonatomic, strong) NSString *centralizedLoginUsername;
@property (nonatomic, strong) NSString *centralizedLoginPassword;
@property (nonatomic, strong) NSString *centralizedLoginOntid;

@property (nonatomic, strong) NSString *addOwnerOntid;
@property (nonatomic, strong) NSString *loginOwnerOntid;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ONTAuthCallback:) name:@"ONTAuthCallbackNotification" object:nil];
    
    [self.tableView setTableFooterView:[UIView new]];
    
    //self.centralizedUsername = @"My username A";
    //self.centralizedPassword = @"123456789";
    //self.centralizedOntid = @"did:ont:APUCws4PYz88uQ7EA2Zv1xtn67YS3vAL9w";
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.text = [self getTitleWithType:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self actionWithType:indexPath.row];
}


- (NSString *)getTitleWithType:(ActionType)type {
    switch (type) {
        case ActionTypeDecentralizedRegister: {
            if (self.decentralizedRegisterOntid) {
                return [NSString stringWithFormat:@"Decentralized registration(%@)", self.decentralizedRegisterOntid];
            } else {
                return @"Decentralized registration";
            }
        }
        case ActionTypeDecentralizedLogin: {
            if (self.decentralizedLoginOntid) {
                return [NSString stringWithFormat:@"Decentralized login(%@)", self.decentralizedLoginOntid];
            } else {
                return @"Decentralized login";
            }
        }
        case ActionTypeApplyClaim:
            return @"Apply Claim";
        case ActionTypeGetClaim:
            return @"Get Claim";
        case ActionTypeAuthorizeClaim:
            return @"Authorize Claim";
        case ActionTypeCentralizedRegister: {
            if (self.centralizedRegisterUsername && self.centralizedRegisterOntid) {
                return [NSString stringWithFormat:@"Centralized registration(%@-%@)", self.centralizedRegisterUsername, self.centralizedRegisterOntid];
            } else {
                return @"Centralized registration";
            }
        }
        case ActionTypeCentralizedLogin: {
            if (self.centralizedLoginUsername && self.centralizedLoginOntid) {
                return [NSString stringWithFormat:@"Centralized login(%@-%@)", self.centralizedLoginUsername, self.centralizedLoginOntid];
            } else {
                return @"Centralized login";
            }
        }
        case ActionTypeCentralizedAddOwner: {
            if (self.addOwnerOntid) {
                return [NSString stringWithFormat:@"Centralized add owner(%@)", self.addOwnerOntid];
            } else {
                return @"Centralized add Owner";
            }
        }
        case ActionTypeCentralizedLoginByOwner: {
            if (self.loginOwnerOntid) {
                return [NSString stringWithFormat:@"Centralized login by Owner(%@)", self.loginOwnerOntid];
            } else {
                return @"Centralized login by Owner";
            }
        }
            
        default:return @"";
    }
}

- (void)actionWithType:(ActionType)type {
    // 获取数据
    [self getQRCodeWithType:type callback:^(NSDictionary *qrCode, NSError *error) {
        if (qrCode && !error) {
            NSString *method = [self getMethodWithType:type];
            
            NSDictionary *params = @{@"urlSchemes": @"authenticatordemo",
                                     @"qrCode": qrCode,
                                     @"method": method
            };
            
            NSError *error = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&error];
            if (!error) {
                NSString *encodeStr = [data base64EncodedStringWithOptions:0];
                NSURL *appURL = [NSURL URLWithString:[NSString stringWithFormat:@"ontologyauthenticator://params?params=%@", encodeStr]];
                if ([[UIApplication sharedApplication] canOpenURL:appURL]) {
                    [[UIApplication sharedApplication] openURL:appURL options:@{} completionHandler:^(BOOL success) {
                        NSLog(@"%d", success);
                    }];
                }
            } else {
                NSLog(@"Error: %@", error.description);
            }
        } else {
            NSLog(@"Error: %@", error.description);
            if (error) {
                [self showText:error.description];
            } else {
                [self showText:@"Unknow Error"];
            }
        }
    }];
}

- (NSString *)getMethodWithType:(ActionType)type {
    switch (type) {
        case ActionTypeDecentralizedRegister:
            return @"OntProtocolRegister";
        case ActionTypeDecentralizedLogin:
            return @"OntProtocolLogin";
        case ActionTypeGetClaim:
            return @"OntProtocolGetClaim";
        case ActionTypeAuthorizeClaim:
            return @"OntProtocolAuthorizeClaim";
        case ActionTypeCentralizedAddOwner:
            return @"OntProtocolAddOwner";
        case ActionTypeCentralizedLoginByOwner:
            return @"OntProtocolLoginByOwner";
            
        default:return @"";
    }
}

- (void)ONTAuthCallback:(NSNotification *)notification {
    NSLog(@"%@", notification.object);
    NSDictionary *dic = (NSDictionary *)notification.object;
    NSString *method = dic[@"method"];
    if ([method isEqualToString:@"OntProtocolRegister"]) {
        self.decentralizedRegisterOntid = dic[@"ontid"];
        [self showText:@"Register Success"];
    } else if ([method isEqualToString:@"OntProtocolLogin"]) {
        self.decentralizedLoginOntid = dic[@"ontid"];
        //[self showText:@"Login Success"];
        [self getDecentralizedLoginStatusCallback:^(NSInteger status, NSError *error) {
            if (status == 1) {
                [self showText:@"Login Success"];
            } else if (status == 2) {
                [self showText:@"Login Failed"];
            } else {
                [self showText:@"Login Unknow"];
            }
        }];
    } else if ([method isEqualToString:@"OntProtocolGetClaim"]) {
        NSLog(@"Claims: %@", dic[@"data"]);
        [self showText:@"GetClaim Success"];
    } else if ([method isEqualToString:@"OntProtocolAuthorizeClaim"]) {
        NSLog(@"Claim: %@", dic[@"data"]);
        [self showText:@"Authorize Success"];
    } else if ([method isEqualToString:@"OntProtocolAddOwner"]) {
        self.addOwnerOntid = dic[@"ontid"];
        [self showText:@"Add Owner Success"];
    } else if ([method isEqualToString:@"OntProtocolLoginByOwner"]) {
        self.loginOwnerOntid = dic[@"ontid"];
        //[self showText:@"Login by Owner Success"];
        [self getOwnerLoginStatusCallback:^(NSInteger status, NSError *error) {
            if (status == 1) {
                [self showText:@"Login Success"];
            } else if (status == 2) {
                [self showText:@"Login Failed"];
            } else {
                [self showText:@"Login Unknow"];
            }
        }];
    }
    [self.tableView reloadData];
}

- (void)showText:(NSString *)text {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = text;
    hud.label.font = [UIFont systemFontOfSize:14.f];
    
    [hud hideAnimated:YES afterDelay:3.0f];
}

- (void)getQRCodeWithType:(ActionType)type callback:(void (^)(NSDictionary *qrcode, NSError *error))callback {
    switch (type) {
        case ActionTypeDecentralizedRegister: {
            [self getDecentralizedRegisterDataCallback:^(NSDictionary *qrcode, NSError *error) {
                callback(qrcode, error);
            }];
            break;
        }
        case ActionTypeDecentralizedLogin: {
            [self getDecentralizedLoginDataCallback:^(NSDictionary *qrcode, NSError *error) {
                callback(qrcode, error);
            }];
            break;
        }
        case ActionTypeApplyClaim: {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Your ontid" message:nil preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(alertController) weakAlert = alertController;
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                NSString *ontid = weakAlert.textFields.firstObject.text;
                NSLog(@"%@", ontid);
                [self applyClaimWithOntid:ontid];
            }];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"Enter the ontid to apply for";
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:doneAction];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }
        case ActionTypeGetClaim: {
            [self getGetClaimDataCallback:^(NSDictionary *qrcode, NSError *error) {
                callback(qrcode, error);
            }];
            break;
        }
        case ActionTypeAuthorizeClaim: {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Username" message:nil preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(alertController) weakAlert = alertController;
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                NSString *userName = weakAlert.textFields.firstObject.text;
                NSLog(@"%@", userName);
                [self getAuthorizeClaimDataWithUserName:userName callback:^(NSDictionary *qrcode, NSError *error) {
                    callback(qrcode, error);
                }];
            }];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"Enter username";
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:doneAction];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }
        case ActionTypeCentralizedRegister: {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Register" message:nil preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(alertController) weakAlert = alertController;
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                NSString *username = weakAlert.textFields.firstObject.text;
                NSString *password = weakAlert.textFields.lastObject.text;
                NSLog(@"%@: %@", username, password);
                [self centralizedRegisterWithUsername:username password:password];
            }];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"Username";
            }];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"Password";
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:doneAction];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }
        case ActionTypeCentralizedLogin: {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Login" message:nil preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(alertController) weakAlert = alertController;
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                NSString *username = weakAlert.textFields.firstObject.text;
                NSString *password = weakAlert.textFields.lastObject.text;
                NSLog(@"%@: %@", username, password);
                [self centralizedLoginWithUsername:username password:password];
            }];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"Username";
            }];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"Password";
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:doneAction];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }
        case ActionTypeCentralizedAddOwner: {
            [self getCentralizedAddOwnerDataCallback:^(NSDictionary *qrcode, NSError *error) {
                callback(qrcode, error);
            }];
            break;
        }
        case ActionTypeCentralizedLoginByOwner: {
            [self getCentralizedLoginByOwnerDataCallback:^(NSDictionary *qrcode, NSError *error) {
                callback(qrcode, error);
            }];
            break;
        }
            
        default:
            break;
    }
}


/// 去中心化的注册
- (void)getDecentralizedRegisterDataCallback:(void (^)(NSDictionary *qrcode, NSError *error))callback {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:@"https://prod.microservice.ont.io/addon-server/api/v1/account/register" parameters:@{@"userName": @"My username 1"} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *result = (NSDictionary *)responseObject;
            NSNumber *errorCode = result[@"error"];
            if ([errorCode isEqualToNumber:@(0)]) {
                NSDictionary *qrCode = result[@"result"][@"qrcode"];
                callback(qrCode, nil);
            } else {
                callback(nil, [NSError errorWithDomain:@"AuthenticatorError" code:errorCode.integerValue userInfo:@{@"error": result[@"desc"]}]);
            }
        } else {
            callback(nil, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        callback(nil, error);
    }];
}

/// 去中心化的登录
- (void)getDecentralizedLoginDataCallback:(void (^)(NSDictionary *qrcode, NSError *error))callback {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:@"https://prod.microservice.ont.io/addon-server/api/v1/account/login" parameters:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *result = (NSDictionary *)responseObject;
            NSDictionary *qrCode = result[@"result"][@"qrcode"];
            self.appId = result[@"result"][@"appId"];
            callback(qrCode, nil);
        } else {
            callback(nil, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        callback(nil, error);
    }];
}

/// 查询登录状态
- (void)getDecentralizedLoginStatusCallback:(void (^)(NSInteger status, NSError *error))callback {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *url = [NSString stringWithFormat:@"https://prod.microservice.ont.io/addon-server/api/v1/account/login/result/%@", self.appId];
    [manager GET:url parameters:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *result = (NSDictionary *)responseObject;
            NSInteger status = [result[@"result"][@"result"] integerValue];
            callback(status, nil);
        } else {
            callback(-1, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        callback(-1, error);
    }];
}

/// 申请 Claim
- (void)applyClaimWithOntid:(NSString *)ontid {
    NSDictionary *params = @{@"name": @"My Name",
                             @"age": @(18),
                             @"answer": @(YES),
                             @"ontid": ontid,
    };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:@"http://a582b9d85545d11ea83090a4ed185dbd-1776841739.ap-southeast-1.elb.amazonaws.com/api/v1/ta/claim" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        [self showText:responseObject[@"result"]];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

/// 获取 Claim（需要先申请 Claim）
- (void)getGetClaimDataCallback:(void (^)(NSDictionary *qrcode, NSError *error))callback {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:@"http://a582b9d85545d11ea83090a4ed185dbd-1776841739.ap-southeast-1.elb.amazonaws.com/api/v1/ta/claim" parameters:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *result = (NSDictionary *)responseObject;
            NSDictionary *qrCode = result[@"result"];
            callback(qrCode, nil);
        } else {
            callback(nil, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        callback(nil, error);
    }];
}

/// 授权 Claim
- (void)getAuthorizeClaimDataWithUserName:(NSString *)userName callback:(void (^)(NSDictionary *qrcode, NSError *error))callback {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:@"http://a643f523b53c911ea83090a4ed185dbd-377407160.ap-southeast-1.elb.amazonaws.com/api/v1/app/claim" parameters:@{@"userName": userName} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *result = (NSDictionary *)responseObject;
            NSDictionary *qrCode = result[@"result"];
            callback(qrCode, nil);
        } else {
            callback(nil, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        callback(nil, error);
    }];
}

/// 中心化的注册
- (void)centralizedRegisterWithUsername:(NSString *)username password:(NSString *)password {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //NSString *userName = [NSString stringWithFormat:@"My username %d", rand()];
    [manager POST:@"http://18.141.44.15:7878/api/v2/app/register" parameters:@{@"userName": username, @"password": password} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *result = (NSDictionary *)responseObject;
            NSDictionary *data = result[@"result"];
            self.centralizedRegisterUsername = data[@"userName"];
            self.centralizedRegisterOntid = data[@"ontid"];
            self.centralizedRegisterPassword = password;
            [self.tableView reloadData];
            [self showText:@"Centralized Register Success"];
        } else {
            [self showText:@"Centralized Register Failed"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        [self showText:@"Centralized Register Failed"];
    }];
}

/// 中心化的登录
- (void)centralizedLoginWithUsername:(NSString *)username password:(NSString *)password {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:@"http://18.141.44.15:7878/api/v2/app/login" parameters:@{@"userName": username, @"password": password} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *result = (NSDictionary *)responseObject;
            NSDictionary *data = result[@"result"];
            self.centralizedLoginUsername = data[@"userName"];
            self.centralizedLoginOntid = data[@"ontid"];
            self.centralizedLoginPassword = password;
            [self.tableView reloadData];
            [self showText:@"Centralized Login Success"];
        } else {
            [self showText:@"Centralized Login Failed"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        [self showText:@"Centralized Login Failed"];
    }];
}

/// 添加 Owner
- (void)getCentralizedAddOwnerDataCallback:(void (^)(NSDictionary *qrcode, NSError *error))callback {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *ontid = self.centralizedRegisterOntid?:self.centralizedLoginOntid;
    if (!ontid) {
        [self showText:@"Please Register or Login First"];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://18.141.44.15:7878/api/v2/app/add-owner/%@", ontid];
    [manager POST:url parameters:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *result = (NSDictionary *)responseObject;
            NSDictionary *qrCode = result[@"result"];
            callback(qrCode, nil);
        } else {
            callback(nil, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        callback(nil, error);
    }];
}

/// 中心化的通过 Owner 登录
- (void)getCentralizedLoginByOwnerDataCallback:(void (^)(NSDictionary *qrcode, NSError *error))callback {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:@"http://18.141.44.15:7878/api/v2/app/login/owner" parameters:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *result = (NSDictionary *)responseObject;
            NSDictionary *qrCode = result[@"result"][@"qrCode"];
            self.appId = result[@"result"][@"id"];
            callback(qrCode, nil);
        } else {
            callback(nil, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        callback(nil, error);
    }];
}

/// 查询登录状态
- (void)getOwnerLoginStatusCallback:(void (^)(NSInteger status, NSError *error))callback {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *url = [NSString stringWithFormat:@"http://18.141.44.15:7878/api/v2/app/login/result/%@", self.appId];
    [manager GET:url parameters:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *result = (NSDictionary *)responseObject;
            NSInteger status = [result[@"result"][@"result"] integerValue];
            callback(status, nil);
        } else {
            callback(-1, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        callback(-1, error);
    }];
}

@end
