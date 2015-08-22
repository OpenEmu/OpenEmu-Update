#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cmath>

#include <vector>
#include <string>
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

// Retrieve the contents of cell x,y (zero based) from LoadedFile f.
std::string LoadedFile_RetrieveCSVCell(const LoadedFile *f, unsigned int x, unsigned int y)
{
   const unsigned char *data = f->data;

   std::string output;

   // Try and find line y of the LoadedFile.
   unsigned int line = 0;

   unsigned int offset_into_data = 0;

   // Skip lines until the line cursor is equal to y.
   while (line < y)
   {
      // Have we reached the end of this file?
      if (offset_into_data == f->data_size) return std::string("");

      // We want to try and find the end of this line.
      if (data[offset_into_data] == '\x0D')
      {
         offset_into_data += 2; // Skip over the newline.
         line++;
      }
      else
      {
         // Skip this byte.
         offset_into_data++;
      }
   }

   // We're on the correct line, now try and find the correct entry.
   unsigned int column = 0;

   // Skip comma stuff until the column cursor is equal to x.
   while (column < x)
   {
      if (offset_into_data == f->data_size) return std::string("");

      if (data[offset_into_data] == '\x0D') return std::string("");
      if (data[offset_into_data] == '\x00') return std::string("");

      if (data[offset_into_data] == ',')
      {
         offset_into_data++;
         column++;
      }
      else
      {
         offset_into_data++;
      }
   }

   // The offset cursor is at the start of the entry we want.
   unsigned int offset_cursor_towards_end_of_entry = offset_into_data;

   while (1)
   {
      bool abort = false;

      if (offset_cursor_towards_end_of_entry == f->data_size) abort = true;

      // Try to find a comma, or the EOF
      if (!abort)
      {
         if (data[offset_cursor_towards_end_of_entry] == ',')    abort = true;
         if (data[offset_cursor_towards_end_of_entry] == '\x0D') abort = true;
         if (data[offset_cursor_towards_end_of_entry] == '\x00') abort = true;
      }

      if (abort)
      {
         // Length of returned string.
         unsigned int length = offset_cursor_towards_end_of_entry - offset_into_data;

         return std::string((const char *)&data[offset_into_data], length);
      }
      else
      {
         offset_cursor_towards_end_of_entry++;
      }
   }

   return output;
}

int main(int argc, char *argv[])
{
   // Converting a csv file that sort of resembles OpenMPT
   // into sms module.

   if (argc < 3)
   {
      printf("Usage: 2013smscsvread input.csv outputsmsmodule.bin\r\n");

      exit(-1);
   }

   LoadedFile f;
   f.load(argv[1]);

   printf("File loading %s.\r\n", f.valid ? "success" : "failure");

   unsigned int line = 0;

   // Try to find the begin: label.
   while (LoadedFile_RetrieveCSVCell(&f,0,line) != std::string("begin"))
   {
      line++;
   }

   // We have selected the begin line.

   FILE *o = fopen(argv[2], "wb");

   if (!o) return -1;

   unsigned int wait_counter = 0;

   std::map<std::string, unsigned int> label_to_offset;

   while (LoadedFile_RetrieveCSVCell(&f,0,line) != std::string("end"))
   {
      bool something_happened_on_this_row = false;

      unsigned int x = 0;

      std::string label_cell = LoadedFile_RetrieveCSVCell(&f,x++,line);

      if (label_cell != std::string(""))
      {
         label_to_offset[label_cell] = ftell(o);
      }

      for (int channel = 0; channel < 4; channel++)
      {
         bool rnp_set = false;
         std::string rnp_string = LoadedFile_RetrieveCSVCell(&f,x++,line);
         if (rnp_string != "") rnp_set = true;

         bool ins_set = false;
         std::string ins_string = LoadedFile_RetrieveCSVCell(&f,x++,line);
         if (ins_string != "") ins_set = true;

         bool vol_set = false;
         std::string vol_string = LoadedFile_RetrieveCSVCell(&f,x++,line);
         if (vol_string != "") vol_set = true;

         bool age_set = false;
         std::string age_string = LoadedFile_RetrieveCSVCell(&f,x++,line);
         if (age_string != "") age_set = true;

         bool ben_set = false;
         std::string ben_string = LoadedFile_RetrieveCSVCell(&f,x++,line);
         if (ben_string != "") ben_set = true;

         if (rnp_set || ins_set || vol_set || age_set || ben_set)
         {
            something_happened_on_this_row = true;

            // If the wait counter is up, output a wait first.
            if (wait_counter > 0)
            {
               unsigned char wait_directive_byte;

               // We need to safely write this out as a series of WAIT directives.
               // WAIT has a maximum size of 111, so I'm going to write out 111s
               // until we're less than 111, and then output the final wait.
               while (wait_counter > 111)
               {
                  // Write the WAIT 111 to the module.
                  wait_directive_byte = 0x80 | 111;
                  fwrite(&wait_directive_byte, 1, 1, o);

                  wait_counter -= 111;
               }

               // Write the WAIT delta_in_rows directive to the module.
               wait_directive_byte = 0x80 | wait_counter;
               fwrite(&wait_directive_byte, 1, 1, o);

               wait_counter = 0;

               // If there was a wait leading to this label,
               // we need to update the offset of the label
               // to put it on the 'AFTER' side of the wait.
               if (label_cell != std::string(""))
               {
                  label_to_offset[label_cell] = ftell(o);
               }
            }

            bool note_off_event_written = false;

            if (rnp_set)
            {
               std::string note_std_string = LoadedFile_RetrieveCSVCell(&f,x-5,line);
               const char *note_string = note_std_string.c_str();

               if (note_string[0] == 'X' || note_string[0] == 'x')
               {
                  unsigned char channel_event_packet_byte_note_off = channel;

                  fwrite(&channel_event_packet_byte_note_off, 1, 1, o);

                  note_off_event_written = true;
               }
            }

            if (!note_off_event_written)
            {
               // Construct command byte based on which parameters were set.
               unsigned char channel_event_packet_byte = channel
                                | (rnp_set ? 0x04 : 0)
                                | (age_set ? 0x08 : 0)
                                | (ins_set ? 0x10 : 0)
                                | (vol_set ? 0x20 : 0)
                                | (ben_set ? 0x40 : 0);

               fwrite(&channel_event_packet_byte, 1, 1, o);

               // Output the channel event with the above parameters.
               if (rnp_set)
               {
                  // Convert ascii string into root note pitch value.
                  std::string note_std_string = LoadedFile_RetrieveCSVCell(&f,x-5,line);
                  const char *note_string = note_std_string.c_str();

                  unsigned char root_note_pitch_value_byte = 0;

                  switch (note_string[0])
                  {
                     case 'c':
                     case 'C':
                     {
                        root_note_pitch_value_byte = 0;
                     }
                     break;
                     case 'd':
                     case 'D':
                     {
                        root_note_pitch_value_byte = 2;
                     }
                     break;
                     case 'e':
                     case 'E':
                     {
                        root_note_pitch_value_byte = 4;
                     }
                     break;
                     case 'f':
                     case 'F':
                     {
                        root_note_pitch_value_byte = 5;
                     }
                     break;
                     case 'g':
                     case 'G':
                     {
                        root_note_pitch_value_byte = 7;
                     }
                     break;
                     case 'a':
                     case 'A':
                     {
                        root_note_pitch_value_byte = 9;
                     }
                     break;
                     case 'b':
                     case 'B':
                     {
                        root_note_pitch_value_byte = 11;
                     }
                     break;
                  }

                  root_note_pitch_value_byte += (note_string[2] - '0') * 12;

                  if (note_string[1] == '#') root_note_pitch_value_byte++;

                  fwrite(&root_note_pitch_value_byte, 1, 1, o);
               }
               if (age_set)
               {
                  unsigned char note_age_value_byte = atoi(age_string.c_str());
                  fwrite(&note_age_value_byte, 1, 1, o);
               }
               if (ins_set)
               {
                  unsigned char instrument_value_byte = atoi(ins_string.c_str());
                  fwrite(&instrument_value_byte, 1, 1, o);
               }
               if (vol_set)
               {
                  unsigned char volume_value_byte = atoi(vol_string.c_str());
                  fwrite(&volume_value_byte, 1, 1, o);
               }
               if (ben_set)
               {
                  unsigned char pitch_bend_value_byte = atoi(ben_string.c_str());
                  fwrite(&pitch_bend_value_byte, 1, 1, o);
               }
            }
         }
      }

      // Now check for directives. These appear in the columns after the channels.
      while (LoadedFile_RetrieveCSVCell(&f,x,line) != std::string(""))
      {
         std::string directive_text  = LoadedFile_RetrieveCSVCell(&f,x++,line);
         std::string directive_value = LoadedFile_RetrieveCSVCell(&f,x++,line);

         // If the wait counter is up, output a wait first.
         if (wait_counter > 0)
         {
            unsigned char wait_directive_byte;

            // We need to safely write this out as a series of WAIT directives.
            // WAIT has a maximum size of 111, so I'm going to write out 111s
            // until we're less than 111, and then output the final wait.
            while (wait_counter > 111)
            {
               // Write the WAIT 111 to the module.
               wait_directive_byte = 0x80 | 111;
               fwrite(&wait_directive_byte, 1, 1, o);

               wait_counter -= 111;
            }

            // Write the WAIT delta_in_rows directive to the module.
            wait_directive_byte = 0x80 | wait_counter;
            fwrite(&wait_directive_byte, 1, 1, o);

            wait_counter = 0;
         }

         if (directive_text == "TEMPO")
         {
            // Write a TEMPO directive using the value in tempo_value_byte
            unsigned char tempo_directive_byte = 0xFE;
            fwrite(&tempo_directive_byte, 1, 1, o);
            unsigned char tempo_value_byte = atoi(directive_value.c_str());
            fwrite(&tempo_value_byte, 1, 1, o);
         }
         else
         if (directive_text == "GOTO")
         {
            // Write a GOTO directive using the values in goto_offset_lower_byte and goto_offset_upper_byte
            unsigned int offset_to_jump_to = label_to_offset[directive_value];

            unsigned char goto_directive_byte = 0xFD;
            fwrite(&goto_directive_byte, 1, 1, o);
            unsigned char goto_offset_lower_byte = offset_to_jump_to & 0xff;
            unsigned char goto_offset_upper_byte = offset_to_jump_to >> 8;
            fwrite(&goto_offset_lower_byte, 1, 1, o);
            fwrite(&goto_offset_upper_byte, 1, 1, o);
         }
         else
         if (directive_text == "STOP")
         {
            unsigned char stop_directive_byte = 0xFF;
            fwrite(&stop_directive_byte, 1, 1, o);
         }
      }

      wait_counter++;

      line++;
   }

   fclose(o);

   return 0;
}
