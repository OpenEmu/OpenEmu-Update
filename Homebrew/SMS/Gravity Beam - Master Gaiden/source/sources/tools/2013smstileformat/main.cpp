#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cmath>

#include <string>
#include <vector>
#include <map>

class LoadedFile
{
   public:
      bool valid;

      // This is where the loaded data is stored.
      unsigned char *data;

      // Number of bytes in read file!
      size_t data_size;

      // Loads the binary music module filename and tries to store
      // it in this structure.
      bool load(const char *filename)
      {
         FILE *f = fopen(filename, "rb");

         // File opening failed...
         if (!f) return false;

         // Move cursor to end of file.
         fseek(f, 0, SEEK_END);

         long filesize = ftell(f);

         data = (unsigned char *)malloc(filesize);

         // Move cursor to start of file.
         fseek(f, 0, SEEK_SET);

         // Load entire contents of file.
         long readbytes = fread(data, 1, filesize, f);

         fclose(f);

         // Fail on incorrect read!
         if (readbytes != filesize)
         {
            free(data);

            valid = false;

            return false;
         }

         valid = true;

         data_size = readbytes;

         return true;
      }

      void deallocate_loaded_data()
      {
         if (valid)
         {
            free(data);

            valid = false;
            data = 0;
            data_size = 0;
         }
      }

      LoadedFile()
      {
         valid = false;
         data = 0;
         data_size = 0;
      }

      ~LoadedFile()
      {
         deallocate_loaded_data();
      }
};

int main(int argc, char *argv[])
{
   if (argc < 3)
   {
      printf("Usage: 2013smstileformat input.raw output.bin\r\n");

      exit(-1);
   }

   LoadedFile f;
   f.load(argv[1]);

   printf("File loading %s.\r\n", f.valid ? "success" : "failure");

   if (!f.valid) return -1;

   // Alright, we've loaded a file of f.data_size bytes.
   // That's d/64 tiles, as we're working with 8x8 tiles in a column.

   FILE *o = fopen(argv[2], "wb");

   const unsigned int tiles = f.data_size / 64;

   for (unsigned int tile = 0; tile < tiles; tile++)
   {
      // (8x8 pixels * 4 bits per pixel) / 8 bits per byte.
      const unsigned int OUTPUT_BITPLANED_TILE_SIZE = (8*8*4) / 8;

      // Prepare memory space for bitplane formatted tile.
      unsigned char output_bytes[OUTPUT_BITPLANED_TILE_SIZE] = {0};

      // Read the indexed colour tile data from the file into bitplane formatter tile:
      const unsigned char *data_from_file = (const unsigned char *)&f.data[tile*8*8];

      for (unsigned int bit = 0; bit < 4; bit++)
      {
         // This is the bit that we're seeking in the original indexed colour tile data:
         unsigned char bit_contribution = 1 << bit;

         for (unsigned int y = 0; y < 8; y++)
         {
            for (unsigned int x = 0; x < 8; x++)
            {
               const unsigned char read_byte = data_from_file[y*8 + x];

               bool bit_present = ((read_byte & bit_contribution) != 0);

               if (bit_present)
               {
                  // Light up the destination bit in the output tile.
                  unsigned char output_light = 1 << (7-x); // Across the bits within a byte is bitplane membership going horizontally. Backwards.

                  // Locate the output byte in the output file.
                  output_bytes[y*4 + bit] |= output_light;
               }
            }
         }
      }

      // Write tile
      fwrite(output_bytes, OUTPUT_BITPLANED_TILE_SIZE, 1, o);
   }

   fclose(o);

   return 0;
}














