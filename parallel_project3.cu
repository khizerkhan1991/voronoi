#include <iostream>
#include <stdlib.h>
#include <math.h>
#include <vector>
#include <chrono>
using namespace std;

  int max_rows = 1000;
  int max_col = 1000;
  int max_color = 255;
  #define N 100000
class Point
{
public:
  Point(int x, int y, int r, int g, int b);
  int getx();
  int gety();
  vector<int> getRGB();
  void setRGB(vector<int> rgb);
  void setShortestDistance(int s_distance);
  int getShortestDistance();
  int x;
  int y;
  int r;
  int g;
  int b;
  int shortest_distance = -1;
};

void Point::setRGB(vector<int> rgb){

  this->r = rgb.at(0);
  this->g = rgb.at(1);
  this->b = rgb.at(2);
}
Point::Point(int x, int y, int r, int g, int b)
{
  this->x = x;
  this->y = y;
  this->r = r;
  this->g = g;
  this->b = b;
  this->shortest_distance = max_col * max_rows;
}
void Point::setShortestDistance(int s_distance){
  
  this->shortest_distance = s_distance;
}
int Point::getx()
{
  return this->x;
}
int Point::gety()
{
  return this->y;
}
int Point::getShortestDistance(){

  return this->shortest_distance;
}
vector<int> Point::getRGB()
{

  vector<int> color;
  color.push_back(this->r);
  color.push_back(this->g);
  color.push_back(this->b);

  return color;
}

void calculate_distanace_from_pixels_to_seeds(vector<Point> pixels, vector<Point> seeds_point);

__device__ int counter =0 ;
__global__
void calculate_distanace_from_pixels_to_seeds(Point *pixels, Point *seeds_point, int seed, int max_rows, int max_col, int *total_pixels){

  int thread = threadIdx.x;

while ( counter < max_rows * max_col -1)
{
  int a = atomicAdd(&counter, 1);
  for (int j = 0; j < seed; j++){

    int x = pixels[a].x - seeds_point[j].x;
    x = x*x;

    int y = pixels[a].y - seeds_point[j].y;
    y = y*y;
    int distance = sqrtf(x + y);

    if(j == 0){
      pixels[a].shortest_distance = distance;

      pixels[a].r = seeds_point[j].r;
      pixels[a].g = seeds_point[j].g;
      pixels[a].b = seeds_point[j].b;
    }

    if(distance <= pixels[a].shortest_distance){
      pixels[a].shortest_distance = distance;

      pixels[a].r = seeds_point[j].r;
      pixels[a].g = seeds_point[j].g;
      pixels[a].b = seeds_point[j].b;

    }}}

   
// for (int i = 0; i < max_rows * max_col; i++)
// {
//   printf("x = %d, y = %d,  r = %d, g = %d, b = %d distance = %d\n", pixels[i].x, pixels[i].y, pixels[i].r, pixels[i].g, pixels[i].b, pixels[i].shortest_distance);
// }

 }



int main(){  
  int seeds;
  cout << "Type number of seeds: ";
  cin >> seeds;

  Point *pixels, *total_seed, *d_pixel, *d_total_seed;
  int *d_total_pixels;

    pixels = (Point*)malloc((max_rows *max_col)*sizeof(Point));
    total_seed = (Point*)malloc(seeds*sizeof(Point));

    cudaMalloc(&d_pixel, (max_rows *max_col)*sizeof(Point));
    cudaMalloc(&d_total_seed, (N)*sizeof(Point));
    cudaMalloc(&d_total_pixels, (max_rows * max_col)*sizeof(int));
  for (int i = 0; i < 1; i++){
    for (int i = 0; i < seeds; i++){
      int x = rand() % max_rows;
      int y = rand() % max_col;
      int r = rand() % max_color;
      int g = rand() % max_color;
      int b = rand() % max_color;
     total_seed[i] = (Point(x, y, r, g, b));
      printf("x= %d, y = %d, r = %d, g = %d, b = %d \n",x , y,r, g, b);
    } }

long count = 0;
  for (int col = 0; col < max_col; col++){
      for (int rows = 0; rows < max_rows; rows++){
        pixels[count] = (Point(col, rows, 0, 0, 0));
        count++;
      } }
    
  //  int value = max_rows * max_col;
    cudaMemcpy(d_pixel, pixels, sizeof(Point)*  (max_rows *max_col), cudaMemcpyHostToDevice);
    cudaMemcpy(d_total_seed, total_seed, sizeof(Point)* seeds, cudaMemcpyHostToDevice);
    cudaMemcpy(d_total_pixels, 0, sizeof(int)*  (max_rows *max_col), cudaMemcpyHostToDevice);

  calculate_distanace_from_pixels_to_seeds<<<1, 1000>>>(d_pixel, d_total_seed, seeds, max_rows, max_col, d_total_pixels);

  
        cudaFree(d_pixel);
        cudaFree(d_total_seed);
        free(pixels);
        free(total_seed);
  return 0;
}

