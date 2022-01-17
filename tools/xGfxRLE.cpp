//X tileset graphics compressor. 2Tie 12/23/2021
#include <stdio.h>
#include <unistd.h>
#include <fstream>
#include <sys/stat.h>

using namespace std;

int main(int argc, char *argv[])
{
	int option;
	char *inName;
	char *outName;
	bool verbose = false;
	int threshold = 2;
	//make sure we have an input and output
	while ((option = getopt(argc, argv, "i:o:t:v")) != -1)
	{
		switch(option)
		{
			case 'i':
				inName = optarg;
				//printf("name obtained\n");
				break;
			case 'o':
				outName = optarg;
				break;
			case 't':
				threshold = atoi(optarg);
				break;
			case 'v':
				verbose = true;
			case ':':
				printf("Please supply a value\n");
				return 1;
			case '?':
				if (optopt == 'o' || optopt == 'i')
				{
					printf("Please supply a value\n");
				}
				else
					printf("Unknown argument!\n");
				return 1;
		}
	}
	
	if(verbose) printf("%s\n", inName);
	
	ifstream inFile;
	ofstream outFile;
	struct stat st;
	
	if(stat(inName, &st) == -1)
	{
		printf("Input file %s stat error!\n", inName);
		return 1;
	}
	int size = st.st_size;
	inFile.open(inName, ios::in | ios::binary);
	
	if(!inFile)
	{
		printf("Input file %s open error!\n", inName);
		return 1;
	}
	char gfxbuffer[size];
	
	if(!inFile.read(gfxbuffer, size))
	{
		printf("Input file %s read error!\n", inName);
		return 1;
	}
	//now we have the contents in a buffer
	inFile.close();
	//let's start reading it!
	int lines = size/2; //lines per bitplane, which is also bytes per bitplane
	int tiles = lines/8; //this is the first bytepair we write!
	
	int rcur = 0; //line reading cursor
	int wcur = 0; //buffer writing cursor
	
	char rlebuf[size+1]; //where we keep the wip RLE buffers
	
	bool bufrun = false; //if we're currently on a same-value run
	
	int potential; //how many same values we've gotten; past the threshold, swap them to a run
	char runval;
	int runcount; //counter for the current run
	
	char readval;
	
	//bitplane loop here
	for(int plane = 0; plane < 2; plane++)
	{
	potential = 0;
	runval = 0;
	runcount = 0;
	bufrun = false;
	//start reading? check which to start with
	if((gfxbuffer[rcur] == gfxbuffer[rcur+2]) && (gfxbuffer[rcur] == gfxbuffer[rcur+4])) //three values to make sure it's a run
	{
		bufrun = true;
		runval = gfxbuffer[rcur];
	}
	else
		wcur++; //leave a space for our sequence size
	//lines loop here!
	for(int l = 0; l < lines; l++)
	{
		readval = gfxbuffer[rcur];
		if(bufrun)
		{
			//on a run of same value
			if(readval == runval)
			{
				runcount++;
				if(runcount == 128)
				{
					//write an entry to the buffer so we don't overflow
					rlebuf[wcur] = (char)(0-runcount);
					rlebuf[wcur+1] = runval;
					wcur+=2;
					//and carry on
					runcount = 0;
				}
			}
			else
			{
				//add our run to the buffer
				rlebuf[wcur] = (char)(0-runcount);
				rlebuf[wcur+1] = runval;
				wcur+=2;
				//and set up the new sequence
				bufrun = false;
				runcount = 1;
				runval = readval;
				potential = 1;
				rlebuf[wcur+1] = readval; //write our temp values
				wcur+=2;
			}
		}
		else
		{
			//on a sequence of different values
			if(readval == runval)
			{
				//same value as last, check threshold
				potential++;
				if(potential > threshold)
				{
					//turn this into a run!
					//finish sequence first
					if(threshold < runcount)
					{
						rlebuf[wcur-runcount-1] = runcount-threshold-1;
					}
					else
						wcur -= 1;
					//set up run
					runcount = potential;
					bufrun = true;
					wcur -= threshold;
				}
				else
				{
					//write the value
					rlebuf[wcur] = readval;
					wcur++;
					runcount++;
				}
			}
			else
			{
				//write the value
				rlebuf[wcur] = readval;
				wcur++;
				runcount++;
				//reset streak
				runval = readval;
				potential = 1;
			}
			if(runcount == 128)
			{
				//start another run!
				rlebuf[wcur-runcount-1] = 128-1;
				runcount = 0;
				wcur++; //leave a new counter spot
			}
		}
		//done with the line
		rcur += 2; //next line on the same plane
	}
	//done with the bitplane, finish up our last run
	if(bufrun)
	{
		rlebuf[wcur] = (char)(0-runcount);
		rlebuf[wcur+1] = runval;
		wcur+=2;
	}
	else
	{
		rlebuf[wcur-runcount-1] = runcount-1;
	}
	rcur = 1;//setup for the second
	}
	//both planes read, now let's write our data!
	//open the file for writing
	outFile.open(outName, ios::out | ios::binary);
	if(!outFile.is_open())
	{
		printf("Problem opening file for writing!\n");
		return 1;
	}
	//size first
	char size1 = (tiles>>8)&0xFF;
	char size2 = tiles&0xFF;
	outFile.write(&size1,1);
	outFile.write(&size2,1);
	//then we dump all of the rlebuf into the file, using wcur as the length!
	outFile.write(rlebuf, wcur);
	outFile.close();
	
	return 0;
}