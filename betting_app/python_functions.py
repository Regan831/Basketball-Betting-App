import pickle
import pandas as pd
import numpy as np
# import bs4
import re
import datetime
from urllib.request import urlopen
import sklearn
import warnings
# from tensorflow import keras

warnings.filterwarnings("ignore")

def clean_team_data():
    df_team_data = pd.read_csv("team_data.csv")
    # df_team_data['year'] = df_team_data['year.x'].map(lambda x: x[0: 2] + x[5:])
    df_team_data['year'] = df_team_data['year.x']
    df_team_data = df_team_data.drop(['Unnamed: 0', 'PTS.x', 'PTS.y', 'year.x', "Team.y", "date", "location.x"], axis=1)
    df_team_data.to_csv("team_data.csv")
    
    df_team_data = pd.read_csv("team_data_recent.csv")
    # df_team_data['year'] = df_team_data['year.x'].map(lambda x: x[0: 2] + x[5:])
    df_team_data['year'] = df_team_data['year.x']
    df_team_data = df_team_data.drop(['Unnamed: 0', 'PTS.x', 'PTS.y', 'year.x', "Team.y", "date", "location.x"], axis=1)
    df_team_data.to_csv("team_data_recent.csv")
    
def create_game_df(df_team1, df_team2,team1_home):
    df_team1['power_conf'] = df_team1['power_conf'].astype(int)
    df_team2['power_conf'] = df_team2['power_conf'].astype(int)
    df_game = df_team1.merge(df_team2, how="inner", on="year")
    df_game = df_game.assign(
        power_conf = df_game.power_conf_x - df_game.power_conf_y,
        exp_off_FGM = df_game.FGM_off_x - df_game.FGM_def_y,
        exp_off_FGA = df_game.FGA_off_x - df_game.FGA_def_y,
        exp_off_3PTM = df_game['3PTM_off_x'] - df_game['3PTM_def_y'],
        exp_off_3PTA = df_game['3PTA_off_x'] - df_game['3PTA_def_y'],
        exp_off_FTA = df_game.FTA_off_x - df_game.FTA_def_y,
        exp_off_FTM = df_game.FTM_off_x - df_game.FTM_def_y,
        exp_off_OREB = df_game.OREB_off_x - df_game.OREB_def_y,
        exp_off_DREB = df_game.DREB_off_x - df_game.DREB_def_y,
        exp_off_REB = df_game.REB_off_x - df_game.REB_def_y,
        exp_off_AST = df_game.AST_off_x - df_game.AST_def_y,
        exp_off_STL = df_game.STL_off_x - df_game.STL_def_y,
        exp_off_BLK = df_game.BLK_off_x - df_game.BLK_def_y,
        exp_off_TO = df_game.TO_off_x - df_game.TO_def_y,
        exp_off_PF = df_game.PF_off_x - df_game.PF_def_y,
        exp_off_PTS = df_game.PTS_off_x - df_game.PTS_def_y,

        exp_def_FGM = df_game.FGM_def_x - df_game.FGM_off_y,
        exp_def_FGA = df_game.FGA_def_x - df_game.FGA_off_y,
        exp_def_3PTM = df_game['3PTM_def_x'] - df_game['3PTM_off_y'],
        exp_def_3PTA = df_game['3PTA_def_x'] - df_game['3PTA_off_y'],
        exp_def_FTA = df_game.FTA_def_x - df_game.FTA_off_y,
        exp_def_FTM = df_game.FTM_def_x - df_game.FTM_off_y,
        exp_def_OREB = df_game.OREB_def_x - df_game.OREB_off_y,
        exp_def_DREB = df_game.DREB_def_x - df_game.DREB_off_y,
        exp_def_REB = df_game.REB_def_x - df_game.REB_off_y,
        exp_def_AST = df_game.AST_def_x - df_game.AST_off_y,
        exp_def_STL = df_game.STL_def_x - df_game.STL_off_y,
        exp_def_BLK = df_game.BLK_def_x - df_game.BLK_off_y,
        exp_def_TO = df_game.TO_def_x - df_game.TO_off_y,
        exp_def_PF = df_game.PF_def_x - df_game.PF_off_y,
        exp_def_PTS = df_game.PTS_def_x - df_game.PTS_off_y,
    )
    df_game['A'] = int(team1_home == "A")
    df_game['H'] = int(team1_home == "H")
    df_game['N'] = int(team1_home == "N")
    df_game.drop(list(df_game.filter(regex = '_x|_y|year|Unnamed|1|onference|hoopr|Team')), axis = 1, inplace = True)
    return df_game

def predict_game(team1, team2, team1_home, year,model = "lrg", recent_bool = False):
    model_lrg = pickle.load(open("model", 'rb'))
    # model_nn = keras.models.load_model("./model_nn.h5")
    
    # model_xgb = pickle.load(open("model_xg", 'rb'))
    
    df_team_data = pd.read_csv("team_data.csv")
    df_team1 = df_team_data[(df_team_data['year'] == year) & (df_team_data['Team'] == team1)]
    if(team2 != "avg"):
        df_team2 = df_team_data[(df_team_data['year'] == year) & (df_team_data['Team'] == team2)]
    else:
        df_team2 = pd.read_csv("avg_team_22.csv")

    if(len(df_team1) == 0):
        print("Team 1 does not exist")
        return 0
    if(len(df_team2) == 0):
        print("Team 2 does not exist")
        return 0
    
    df_game = create_game_df(df_team1, df_team2,team1_home)
    prediction = model_lrg.predict_proba(df_game)[:,1]

    if(model == 'lrg'):
        prediction = model_lrg.predict_proba(df_game)[:,1]
    # elif(model == 'nn'):
        # df_game.drop(['exp_def_PTS', 'exp_off_PTS'], axis =1, inplace=True)
        # prediction = model_nn.predict_proba(df_game)[:,0]
    # elif(model == 'ensemble'):
        # prediction_xgb = model_xgb.predict_proba(df_game)[:,1]
        # df_game.drop(['exp_def_PTS', 'exp_off_PTS'], axis =1, inplace=True)
        # prediction = .5 * prediction_xgb + .5 * model_nn.predict_proba(df_game)[:,0]
    else:
        return "Invalid model selection."
        
    if(recent_bool == True):
        df_team_data = pd.read_csv("team_data_recent.csv")
        df_team1 = df_team_data[(df_team_data['year'] == year) & (df_team_data['Team'] == team1)]
        df_team2 = df_team_data[(df_team_data['year'] == year) & (df_team_data['Team'] == team2)]
        df_game = create_game_df(df_team1, df_team2,team1_home)
        prediction = (model_lrg.predict_proba(df_game)[:,1] * .5) + (.5 * prediction)
       
    
    return prediction[0]

def get_alt_names():
    df_alt_names = []
    df_alt_names.append(["Mississippi", "Ole Miss"])
    df_alt_names.append(["St. Josephs (PA)", "Saint Joseph's"])
    df_alt_names.append(["CS Sacramento", "Sacramento State"])
    df_alt_names.append(["St. Johns", "St. John's"])
    df_alt_names.append(["Southern Cal", "USC"])
    df_alt_names.append(["American", "American University"])
    df_alt_names.append(["Bethune Cookman", "Bethune-Cookman"])
    df_alt_names.append(["Florida AM", "Florida A&M"])
    df_alt_names.append(["Mississippi Valley St.", "Mississippi Valley State"])
    df_alt_names.append(["Alabama AM", "Alabama A&M"])
    df_alt_names.append(["Southern AM", "Southern"])
    df_alt_names.append(["Prairie View AM", "Prairie View A&M"])
    df_alt_names.append(["College of Charleston", "Charleston"])
    df_alt_names.append(["William Mary", "William & Mary"])
    df_alt_names.append(["Bowling Green State", "Bowling Green"])
    df_alt_names.append(["Texas Christian", "TCU"])
    df_alt_names.append(["CS Northridge", "CSU Northridge"])
    df_alt_names.append(["East Tennessee St.", "East Tennessee State"])
    df_alt_names.append(["Virginia Military", "VMI"])
    df_alt_names.append(["UT Chattanooga", "Chattanooga"])
    df_alt_names.append(["Southern Methodist", "SMU"])
    df_alt_names.append(["Massachusetts", "UMass"])
    df_alt_names.append(["Miami (FL)", "Miami"])
    df_alt_names.append(["Texas Rio Grande", "UT Rio Grande Valley"])
    df_alt_names.append(["Virginia Commonwealth", "VCU"])
    df_alt_names.append(["St. Louis", "Saint Louis"])
    df_alt_names.append(["North Carolina State", "NC State"])
    df_alt_names.append(["Texas AM", "Texas A&M"])
    # df_alt_names.append(["California Baptist", "Cal Baptist"])
    df_alt_names.append(["Seattle", "Seattle U"])
    df_alt_names.append(["UNC Charlotte", "Charlotte"])
    df_alt_names.append(["USC Upstate", "South Carolina Upstate"])
    df_alt_names.append(["UMASS Lowell", "UMass Lowell"])
    df_alt_names.append(["North Carolina AT", "North Carolina A&T"])
    df_alt_names.append(["Central Florida", "UCF"])
    df_alt_names.append(["UW Green Bay", "Green Bay"])
    df_alt_names.append(["Middle Tennessee St.", "Middle Tennessee"])
    df_alt_names.append(["UW Milwaukee", "Milwaukee"])
    df_alt_names.append(["Austin Peay State", "Austin Peay"])
    df_alt_names.append(["SE Missouri State", "Southeast Missouri State"])
    df_alt_names.append(["CS Bakersfield", "CSU Bakersfield"])
    df_alt_names.append(["St. Marys (CA)", "Saint Mary's"])
    df_alt_names.append(["St Francis (NY)", "St Francis (BKN)"])
    df_alt_names.append(["LIU Brooklyn", "Long Island University"])
    df_alt_names.append(["Central Connecticut St.", "Central Connecticut"])
    df_alt_names.append(["Gardner Webb", "Gardner-Webb"])
    df_alt_names.append(["Hawaii", "Hawai'i"])
    df_alt_names.append(["CS Long Beach", "Long Beach State"])
    df_alt_names.append(["Illinois-Chicago", "UIC"])
    df_alt_names.append(["Louisiana-Monroe", "UL Monroe"])
    df_alt_names.append(["Louisiana-Lafayette", "Lafayette"])
    df_alt_names.append(["Nebraska-Omaha", "Omaha"])
    df_alt_names.append(["Texas-Arlington", "UT Arlington"])
    df_alt_names.append(["Texas-San Antonio", "UTSA"])
    df_alt_names.append(["Florida Intl", "Florida International"])
    df_alt_names.append(["Loyola-Chicago", "Loyola Chicago"])
    df_alt_names.append(["Missouri-Kansas City", "Kansas City"])
    df_alt_names.append(["Loyola-Marymount", "Loyola Marymount"])
    df_alt_names.append(["Texas AM-CC", "Texas A&M-CC"])
    df_alt_names.append(["IUPU-Fort Wayne", "Purdue Fort Wayne"])
    df_alt_names.append(["Monmouth (NJ)", "Monmouth"])
    df_alt_names.append(["St. Peters", "Saint Peter's"])
    df_alt_names.append(["SUNY-Buffalo", "Buffalo"])
    df_alt_names.append(["Cal Poly Slo", "Cal Poly"])
    df_alt_names.append(["MD-Eastern Shore", "Maryland-Eastern Shore"])
    df_alt_names.append(["Grambling State", "Grambling"])
    df_alt_names.append(["New Jersey Tech", "NJIT"])
    df_alt_names.append(["Nicholls State", "Nicholls"])
    df_alt_names.append(["CS Fullerton", "CSU Fullerton"])
    df_alt_names.append(["Louisiana State", "LSU"])
    df_alt_names.append(["Connecticut", "UConn"])
    df_alt_names.append(["Miami (OH)", "Miami OH"])
    df_alt_names.append(["San Jose State", "San JosÃ© State"])
    df_alt_names.append(["Loyola-Maryland", "Loyola MD"])
    df_alt_names.append(["MD-Baltimore County", "UMBC"])
    df_alt_names.append(["St. Francis (NY)", "St. Francis BKN"])
    df_alt_names.append(["St. Francis (PA)", "St. Francis PA"])
    df_alt_names.append(["Mount St. Marys", "Mount St. Mary's"])
    df_alt_names.append(["Indiana-Purdue", "IUPUI"])
    df_alt_names.append(["Arkansas-Little Rock", "Little Rock"])
    df_alt_names.append(["McNeese State", "McNeese"])
    df_alt_names.append(["Sam Houston State", "Sam Houston"])
    
    df_alt_names = pd.DataFrame(df_alt_names, columns = ['odd_name', 'correct_name'])
    return df_alt_names
    
def expected_value(team, team_odds, team_win, year="2021-22"):
    
    if team_odds > 0:
        exp_team = (team_win * (team_odds/100)) - (1-team_win)
    else:
        exp_team = (team_win * 1/(-team_odds / 100)) - (1-team_win)
        
    return exp_team
    
def get_todays_odds(year = '2021-22'):
    game_info = pd.read_csv("odds.csv")

    df_alt_names = get_alt_names()
    game_info['year'] = year
    
    game_info['exp_win_away'] = game_info.apply(lambda x: round(predict_game(x.away_team, x.home_team,"A", x.year, model="lrg"), 3) if x.N != 'N' else round(predict_game(x.away_team, x.home_team,"N", x.year, model="lrg"), 3), axis=1)
    game_info['exp_win_home'] = game_info.apply(lambda x: round(predict_game(x.home_team, x.away_team,"H", x.year, model="lrg"), 3) if x.N != 'N' else round(predict_game(x.home_team, x.away_team,"N", x.year, model="lrg"), 3), axis=1)
    
    game_info['exp_win_away_recent'] = game_info.apply(lambda x: round(predict_game(x.away_team, x.home_team,"A", x.year, model="lrg", recent_bool=True), 3) if x.N != 'N' else round(predict_game(x.away_team, x.home_team,"N", x.year, model="lrg", recent_bool=True), 3), axis=1)
    game_info['exp_win_home_recent'] = game_info.apply(lambda x: round(predict_game(x.home_team, x.away_team,"H", x.year, model="lrg", recent_bool=True), 3) if x.N != 'N' else round(predict_game(x.home_team, x.away_team,"N", x.year, model="lrg", recent_bool=True), 3), axis=1)
    
    # game_info['exp_win_away_nn'] = game_info.apply(lambda x: round(predict_game(x.away_team, x.home_team,"A", x.year, model="ensemble"), 3), axis=1)
    # game_info['exp_win_home_nn'] = game_info.apply(lambda x: round(predict_game(x.home_team, x.away_team,"H", x.year, model="ensemble"), 3), axis=1)

    game_info['away_odds_ml'] = game_info['away_odds_ml'].apply(lambda x: pd.to_numeric(x, downcast='signed')).reset_index( drop=True)
    game_info['home_odds_ml'] = game_info['home_odds_ml'].apply(lambda x: pd.to_numeric(x, downcast='signed')).reset_index( drop=True)
    
        
    game_info['exp_value_away'] =game_info.apply(lambda x: round(expected_value(x.away_team, x.away_odds_ml, x.exp_win_away), 4), axis=1)
    game_info['exp_value_home'] =game_info.apply(lambda x: round(expected_value(x.home_team, x.home_odds_ml, x.exp_win_home), 4), axis=1)
    game_info['exp_value_away_recent'] =game_info.apply(lambda x: round(expected_value(x.away_team, x.away_odds_ml, x.exp_win_away_recent), 4), axis=1)
    game_info['exp_value_home_recent'] =game_info.apply(lambda x: round(expected_value(x.home_team, x.home_odds_ml, x.exp_win_home_recent), 4), axis=1)
    # game_info['exp_value_away_nn'] =game_info.apply(lambda x: round(expected_value(x.away_team, x.away_odds, x.exp_win_away_nn), 4), axis=1)
    # game_info['exp_value_home_nn'] =game_info.apply(lambda x: round(expected_value(x.home_team, x.home_odds, x.exp_win_home_nn), 4), axis=1)

    
    game_info.to_csv('today_odds.csv')

def return_amt(bet,odds):
    odds = int(odds)
    if odds > 0:
        return bet * (odds/100)
    else:
        return bet / (-odds / 100)
        
def handle_bet(bet,odds, result):
    print(bet, odds, result)
    if(result == True):
        return return_amt(bet,odds)
    else:
        return -bet

def record_day_results():
    df_results = pd.read_csv("today_odds.csv")
    df_results["result"] = [1,0,0]
    df_results["bet"] = df_results.apply(lambda x: round(100 * x.exp_value_home,4) if(float(x.exp_value_home) > 0) else(round(100 * x.exp_value_away,4) if (int(x.exp_value_away > 0)) else 0), axis=1)
    df_results["return"] = df_results.apply(lambda x: round(handle_bet(x.bet,x.home_odds_ml,x.result==2), 4) if(float(x.exp_value_home) > 0) else(round(handle_bet(x.bet,x.away_odds_ml,x.result==1),4) if (int(x.exp_value_away > 0)) else 0), axis=1)
    df_results["expected_return"] = df_results.apply(lambda x: round(x.bet * x.exp_value_home, 4) if(float(x.exp_value_home) > 0) else(round(x.bet * x.exp_value_away,4) if (int(x.exp_value_away > 0)) else 0), axis=1)
    df_results = df_results[df_results['result'] != 0]
    
    df_results["bet_recent"] = df_results.apply(lambda x: round(100 * x.exp_value_home_recent,4) if(float(x.exp_value_home_recent) > 0) else(round(100 * x.exp_value_away_recent,4) if (int(x.exp_value_away_recent > 0)) else 0), axis=1)
    df_results["return_recent"] = df_results.apply(lambda x: round(handle_bet(x.bet_recent,x.home_odds_ml,x.result==2), 4) if(float(x.exp_value_home_recent) > 0) else(round(handle_bet(x.bet_recent,x.away_odds_ml,x.result==1),4) if (int(x.exp_value_away_recent > 0)) else 0), axis=1)
    df_results["expected_return_recent"] = df_results.apply(lambda x: round(x.bet_recent * x.exp_value_home_recent, 4) if(float(x.exp_value_home_recent) > 0) else(round(x.bet_recent * x.exp_value_away_recent,4) if (int(x.exp_value_away_recent > 0)) else 0), axis=1)
    
    # df_results["bet_nn"] = df_results.apply(lambda x: round(100 * x.exp_value_home_nn,4) if(float(x.exp_value_home_nn) > 0) else(round(100 * x.exp_value_away_nn,4) if (int(x.exp_value_away_nn > 0)) else 0), axis=1)
    # df_results["return_nn"] = df_results.apply(lambda x: round(handle_bet(x.bet_nn,x.home_odds_ml,x.result==2), 4) if(float(x.exp_value_home_nn) > 0) else(round(handle_bet(x.bet_nn,x.away_odds_ml,x.result==1),4) if (int(x.exp_value_away_nn > 0)) else 0), axis=1)
    # df_results["expected_return_nn"] = df_results.apply(lambda x: round(x.bet_nn * x.exp_value_home_nn, 4) if(float(x.exp_value_home_nn) > 0) else(round(x.bet_nn * x.exp_value_away_nn,4) if (int(x.exp_value_away_nn > 0)) else 0), axis=1)

    df_result_all = pd.read_csv('df_bet_results.csv',index_col=[0])
    df_result_all = pd.concat([df_result_all, df_results])
    df_result_all.drop(list(df_result_all.filter(regex = 'Unnamed')), axis = 1, inplace = True)
    
    df_result_all.to_csv("df_bet_results.csv")
