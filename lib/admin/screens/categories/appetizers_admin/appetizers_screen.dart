import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_project/admin/all_meals_cubit/cubit.dart';
import 'package:food_project/admin/all_meals_cubit/states.dart';
import 'package:food_project/admin/home_screen.dart';
import 'package:food_project/admin/screens/edit_meal/edit_meal_screen.dart';
import 'package:food_project/screens/categories/appetizers/cubit/cubit.dart';
import 'package:food_project/screens/categories/appetizers/cubit/states.dart';
import 'package:food_project/shared/componentes/components.dart';

class AppetizersAdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Appetizers'),
        actions: [
          SizedBox(width: 10,),
          InkWell(
            onTap: (){navigateAndFinish(context, AdminHomeScreen());},
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home,color: Colors.white,),
                  Text('HOME'),
                ],
              ),
            ),
          ),
          SizedBox(width: 10,),
        ],
      ),
      drawer: buildAdminDrawer(context),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AllMealsCubit(),
          ),
        ],
        child: BlocProvider(
            create: (context) => AppetizersCubit()..appetizers(),
            child: BlocConsumer<AppetizersCubit, AppetizersStates>(
              listener: (context, state) {
                if (state is AppetizersStateLoading) {
                  print('AppetizersStateLoading');
                  return buildProgress(context: context, text: "please Wait.. ");
                }
                if (state is AppetizersStateSuccess) {
                  print('AppetizersStateSuccess');
                }
                if (state is AppetizersStateError) {
                  print('AppetizersStateError');
                  Navigator.pop(context);
                  return buildProgress(
                    context: context,
                    text: "${state.error.toString()}",
                    error: true,
                  );
                }
              },
              builder: (context, state) {
                List appetizersMeals = AppetizersCubit.get(context).appetizersMeals;
                List chickenMealsId = AppetizersCubit.get(context).appetizersMealsId;
                return ConditionalBuilder(
                  condition: state is AppetizersStateLoading   ,
                  builder: (context) => Center(child: CircularProgressIndicator(),),
                  fallback:(context)=> BlocConsumer<AllMealsCubit,AllMealsStates>(
                    listener: (context,state){},
                    builder: (context,state){
                      return  Column(
                          children: [
                            Expanded(
                              child: ListView.separated(
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                                itemBuilder: (context, index) =>
                                    buildMealItems(
                                        imageUrl: appetizersMeals[index]['imageLink'].toString(),
                                        price: appetizersMeals[index]['MealPrice'].toString(),
                                        title: appetizersMeals[index]['MealTitle'].toString(),
                                        dec: appetizersMeals[index]['MealDescription'].toString(),
                                        buttonTitle: 'Delete Meal',
                                        buttonColor:Colors.red,
                                        buttonFunction: () {
                                          if (chickenMealsId != null) {
                                            AllMealsCubit.get(context).deleteMeal(
                                                documentId: chickenMealsId,
                                                index: index);
                                            navigateTo(context,AppetizersAdminScreen());
                                          }
                                        },
                                      isAdmin: true,
                                      buttonColor2: Colors.green,
                                      buttonTitle2: 'Edit Meal',
                                      buttonFunction2: (){navigateAndFinish(context, EditMealScreen(
                                      index: index,
                                      meals: appetizersMeals,
                                      mealsId: chickenMealsId,
                                      ),);}

                                    ),
                                separatorBuilder: (context, index) => SizedBox(
                                  height: 25.0,
                                ),
                                itemCount: appetizersMeals.length,
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                          ]);
                    },
                  )
                );
              },
            ),
          ),
      ),
    );
  }
}