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

struct tile8x8_rawdata
{
   unsigned char index[8*8];
};

bool operator==(const tile8x8_rawdata &a, const tile8x8_rawdata &b)
{
   for (unsigned int i = 0; i < 64; i++)
   {
      if (a.index[i] != b.index[i]) return false;
   }

   return true;
}

int main(int argc, char *argv[])
{
   if (argc < 4)
   {
      printf("Usage: 2013megatilemanager 8x8tiles.raw 16by16tiles.raw output.z80asm");

      exit(-1);
   }

   LoadedFile tiles8x8;
   tiles8x8.load(argv[1]);
   printf("File loading %s.\r\n", tiles8x8.valid ? "success" : "failure");
   if (!tiles8x8.valid) return -1;

   LoadedFile tiles16x16;
   tiles16x16.load(argv[2]);
   printf("File loading %s.\r\n", tiles16x16.valid ? "success" : "failure");
   if (!tiles16x16.valid) return -1;

   // Load every tile in the 8x8 into an array of tiles
   unsigned int tile8x8_count = tiles8x8.data_size/64;

   const tile8x8_rawdata *input_tiles_as_rawdata = (const tile8x8_rawdata *)tiles8x8.data;

   FILE *o = fopen(argv[3], "wb");

   unsigned int tile16x16_count = tiles16x16.data_size/256;

   for (unsigned int t = 0; t < tile16x16_count; t++)
   {
      fprintf(o,".db ");

      for (unsigned int subtile = 0; subtile < 4; subtile++)
      {

         const tile8x8_rawdata &incoming_tile = (*((const tile8x8_rawdata *)(&tiles16x16.data[(t*4+subtile)*64])));

         for (unsigned int check_dex = 0; check_dex < tile8x8_count; check_dex++)
         {
            const tile8x8_rawdata &dex_tile = input_tiles_as_rawdata[check_dex];

            if (incoming_tile == dex_tile)
            {
               fprintf(o,"%d,",check_dex);
               break;
            }
         }
      }

      fprintf(o,"\r\n");
   }

   fclose(o);

   return 0;
}














