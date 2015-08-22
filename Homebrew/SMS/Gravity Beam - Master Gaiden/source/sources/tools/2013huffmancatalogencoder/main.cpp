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

std::string LoadedFile_RetrievePlaintextLineAtCursor(const LoadedFile &loaded_file, unsigned int cursor_position)
{
   if (loaded_file.valid == false) return std::string("");

   // Gather up characters from the cursor position until we hit an EOL or run out of chars.
   std::string output = std::string("");

   while ((cursor_position < loaded_file.data_size)
       && (loaded_file.data[cursor_position] != '\x0D')
       && (loaded_file.data[cursor_position] != '\x0A'))
   {
      char temp_c_string[2] = {0,0};

      temp_c_string[0] = loaded_file.data[cursor_position];

      output = output + std::string(temp_c_string);

      cursor_position++;
   }

   return output;
}

std::vector<char> std_string_to_std_vector_char(const std::string &s)
{
   std::vector<char> v;

   for (unsigned int i = 0; i < s.length(); i++)
   {
      v.push_back(s.at(i));
   }

   v.push_back(0);

   return v;
}

std::string std_string_trim_whitespace(const std::string &s)
{
   std::vector<char> s_vector_char = std_string_to_std_vector_char(s);
   char *s_vector_char_ptr = &s_vector_char[0];

   // Strip newline characters.
   {
      char *string_ptr;
      while((string_ptr = strpbrk(s_vector_char_ptr, "\r\n")) != NULL)
      {
         *string_ptr = 0;
      }
   }

   // Trim trailing spaces.
   {
      char *string_ptr = s_vector_char_ptr + (strlen(s_vector_char_ptr) - 1);
      while ((string_ptr >= s_vector_char_ptr) && (*string_ptr == ' '))
      {
         *string_ptr = 0;
         string_ptr--;
      }
   }

   // Trim preceding spaces by constructing a pointer to the first printable char.
   char *string_start_ptr = s_vector_char_ptr;
   {
      while (*string_start_ptr == ' ')
      {
         string_start_ptr++;
      }
   }

   std::string cleaned_string = std::string(string_start_ptr);

   return cleaned_string;
}

struct HuffmanCatalogFile
{
   std::string output_asm_file_filename;

   std::string asm_token_prefix;

   enum Compression
   {
      NIBBLE,
      BYTE
   };

   Compression compression;

   std::vector<std::string> files_to_load;
};

// Tries to load the file from the given location
// Returns true on success and valid format, false on failure.
bool HuffmanCatalogFile_fromLoadedFile(const LoadedFile &loaded_file, HuffmanCatalogFile &h)
{
   // Can't do anything if we haven't loaded the file already.
   if (loaded_file.valid == false) return false;

   h.compression = HuffmanCatalogFile::NIBBLE;

   // State machine for the parser.
   enum LoadCatalogFile_ParsingMode
   {
      PARSE_TYPELESS, // We haven't encountered a directive yet.
      PARSE_OUTPUT_ASM_FILE_FILENAME,
      PARSE_ASM_TOKEN_PREFIX,
      PARSE_COMPRESSION_TYPE,
      PARSE_FILE_LISTING,
   };

   LoadCatalogFile_ParsingMode parse_mode = PARSE_TYPELESS;

   unsigned int cursor_into_loaded_file = 0;

   while (true)
   {
      if (cursor_into_loaded_file >= loaded_file.data_size)
      {
         break;
      }

      // Read a line from the file.
      std::string raw_line_read_from_file = LoadedFile_RetrievePlaintextLineAtCursor(loaded_file, cursor_into_loaded_file);

      // Advance reading cursor
      int old_cursor_into_loaded_file = cursor_into_loaded_file; // Used for debug
      cursor_into_loaded_file += raw_line_read_from_file.length() + 1;

      // Get clean string
      std::string trimmed_string = std_string_trim_whitespace(raw_line_read_from_file);

      // Ignore blank lines
      if (trimmed_string.length() == 0)
      {
         continue;
      }

      // Ignore lines beginning with a ; character
      if (trimmed_string.at(0) == ';')
      {
         continue;
      }

      //printf("At %d, analysing '%s'.\r\n", old_cursor_into_loaded_file, trimmed_string.c_str());

      // If it's a directive, switch to that parse mode.
      if (trimmed_string == "OUTPUT_FILE_FILENAME")
      {
         parse_mode = PARSE_OUTPUT_ASM_FILE_FILENAME;

         continue;
      }
      if (trimmed_string == "ASM_TOKEN_PREFIX")
      {
         parse_mode = PARSE_ASM_TOKEN_PREFIX;

         continue;
      }
      if (trimmed_string == "COMPRESSION_TYPE")
      {
         parse_mode = PARSE_COMPRESSION_TYPE;

         continue;
      }
      if (trimmed_string == "FILE_LISTING")
      {
         parse_mode = PARSE_FILE_LISTING;

         continue;
      }

      switch (parse_mode)
      {
         case (PARSE_TYPELESS) :
         {
            // Nothing. No mode is active.
         }
         break;

         case (PARSE_OUTPUT_ASM_FILE_FILENAME)   : { h.output_asm_file_filename   = trimmed_string; } break;
         case (PARSE_ASM_TOKEN_PREFIX)           : { h.asm_token_prefix           = trimmed_string; } break;

         case (PARSE_COMPRESSION_TYPE) :
         {
            if (trimmed_string == "byte")
            {
               h.compression = HuffmanCatalogFile::BYTE;
            }
         }
         break;
         case (PARSE_FILE_LISTING) :
         {
            h.files_to_load.push_back(trimmed_string);
         }
         break;
      }
   }

   return true;
}

const unsigned int NO_INPUT_ELEMENT_ENTRIES = 16;
const unsigned int ENCODING_STRING_MAX_LENGTH = 256;

struct huffman_bag
{
   unsigned int my_designation; // 0 or 1

   huffman_bag *bag_0;
   huffman_bag *bag_1;

   bool owns_entry[NO_INPUT_ELEMENT_ENTRIES]; // This is an array of bools for the entries that this bag owns.
};

huffman_bag *huffman_bag_create()
{
   huffman_bag *bag = new huffman_bag;

   bag->bag_0 = bag->bag_1 = 0;

   for (unsigned int entry = 0; entry < NO_INPUT_ELEMENT_ENTRIES; entry++)
   {
      bag->owns_entry[entry] = 0;
   }

   return bag;
}

void huffman_bag_destroy(huffman_bag *bag)
{
   if (!bag) return;

   huffman_bag_destroy(bag->bag_0);
   huffman_bag_destroy(bag->bag_1);
}

unsigned int huffman_bag_total_population(huffman_bag *bag, unsigned int entry_populations[])
{
   if (!bag) return 0;

   unsigned int total_population = 0;

   for (unsigned int entry = 0; entry < NO_INPUT_ELEMENT_ENTRIES; entry++)
   {
      if (bag->owns_entry[entry]) total_population += entry_populations[entry];
   }

   return total_population;
}

unsigned int huffman_bag_no_members(huffman_bag *bag)
{
   if (!bag) return 0;

   unsigned int total_members = 0;

   for (unsigned int byte = 0; byte < NO_INPUT_ELEMENT_ENTRIES; byte++)
   {
      if (bag->owns_entry[byte]) total_members++;
   }

   return total_members;
}

// Construct miniature bags within this bag that own subsets of the
// bytes of their parent bag, with the aim of producing equally weighted
// bags!
void huffman_bag_split(huffman_bag *bag, unsigned int entry_populations[])
{
   // Don't split a bag that only contains one member.
   if (huffman_bag_no_members(bag) == 1) return;

   bag->bag_0 = huffman_bag_create();
   bag->bag_0->my_designation = 0;
   bag->bag_1 = huffman_bag_create();
   bag->bag_1->my_designation = 1;

   // Split a bag that contains two members into fifty fifty.
   if (huffman_bag_no_members(bag) == 2)
   {
      // Find the first element this bag owns.
      unsigned int entry = 0;

      for (; entry < NO_INPUT_ELEMENT_ENTRIES; entry++)
      {
         if (bag->owns_entry[entry])
         {
            bag->bag_0->owns_entry[entry] = true;
            entry++;
            break;
         }
      }

      // Find the other element this bag owns.

      for (; entry < NO_INPUT_ELEMENT_ENTRIES; entry++)
      {
         if (bag->owns_entry[entry])
         {
            bag->bag_1->owns_entry[entry] = true;
            break;
         }
      }

      return;
   }

   // This bag contains an arbitrary number of members. UH OH.
   unsigned int total_population = huffman_bag_total_population(bag, entry_populations);

   unsigned int half_population = total_population/2;

   // ARSE METHOD:
   // Continually place elements into bag 0 until it is at least half full
   // If you've got a better solution to the bin packing problem, you might
   // be able to save DOZENS of bytes (in the compressed blocks) on my version!!!
   unsigned int entry = 0;

   unsigned int cumulative_weight = 0;

   unsigned int cumulative_members = 0;
   unsigned int my_members = huffman_bag_no_members(bag);

   for (; entry < NO_INPUT_ELEMENT_ENTRIES; entry++)
   {
      if (!bag->owns_entry[entry]) continue;

      bag->bag_0->owns_entry[entry] = true;

      // Break if we now own all but one of the parent bags elements.
      cumulative_members++;

      if (cumulative_members == (my_members-1))
      {
         entry++;
         break;
      }

      // Break if we now weigh over half the weight of the parent bag.
      cumulative_weight += entry_populations[entry];

      if (cumulative_weight >= half_population)
      {
         entry++;
         break;
      }
   }

   for (; entry < NO_INPUT_ELEMENT_ENTRIES; entry++)
   {
      if (!bag->owns_entry[entry]) continue;

      bag->bag_1->owns_entry[entry] = true;
   }

   // Now split these bags.
   huffman_bag_split(bag->bag_0, entry_populations);
   huffman_bag_split(bag->bag_1, entry_populations);
}

// Search for the given byte in this bag and all subsequenct bags, appending the bag's
// current designation to the beginning of the encoding string. NULL after that
// if it's the terminal bag.
void huffman_bag_return_encoding_string(huffman_bag *bag, unsigned int entry, char *encoding_string)
{
   encoding_string[0] = '0' + bag->my_designation;

   // If this is a terminal bag, put a zero.
   if (bag->bag_0 == 0) { encoding_string[1] = 0; return; }

   // Look for the subbag that owns this entry
   if (bag->bag_0->owns_entry[entry])
   {
      huffman_bag_return_encoding_string(bag->bag_0, entry, encoding_string + 1);
   }
   else
   {
      huffman_bag_return_encoding_string(bag->bag_1, entry, encoding_string + 1);
   }
}

struct HuffmanConstructDecompressorContext
{
   std::vector<char> current_bit_stream_to_get_here;

   std::map<std::string, unsigned char> map_sequences_to_chars;

   HuffmanCatalogFile *catalog_file_info;
};

void huffman_construct_decompressor(FILE *asm_file, HuffmanConstructDecompressorContext &context, huffman_bag *bag)
{
   // This recursive function constructs a huffman decoder based on the huffman tree node bag.
   // If there's a decision, it recurses.

   const char *asm_token_prefix = context.catalog_file_info->asm_token_prefix.c_str();

   fprintf(asm_file, "%sdecompress_at_", asm_token_prefix);

   if (context.current_bit_stream_to_get_here.size() > 0)
   {
      for (unsigned int i = 0; i < context.current_bit_stream_to_get_here.size(); i++)
      {
         fprintf(asm_file, "%c", context.current_bit_stream_to_get_here[i]);
      }
   }
   else
   {
      fprintf(asm_file, "start");
   }

   fprintf(asm_file, ":\r\n");

   if (bag->bag_0 != NULL)
   {
      // There is a decision.

      fprintf(asm_file, "    call   %sdecompress_get_next_bit\r\n", asm_token_prefix);

      fprintf(asm_file, "    jr     c,%sdecompress_at_", asm_token_prefix);
      for (unsigned int i = 0; i < context.current_bit_stream_to_get_here.size(); i++)
      {
         fprintf(asm_file, "%c", context.current_bit_stream_to_get_here[i]);
      }
      fprintf(asm_file, "1\r\n");

      context.current_bit_stream_to_get_here.push_back('0');
      huffman_construct_decompressor(asm_file, context, bag->bag_0);
      context.current_bit_stream_to_get_here.pop_back();

      //fprintf(asm_file, "    jp     %sdecompress_at_", asm_token_prefix);
      //for (unsigned int i = 0; i < context.current_bit_stream_to_get_here.size(); i++)
      //{
      //   fprintf(asm_file, "%c", context.current_bit_stream_to_get_here[i]);
      //}
      //fprintf(asm_file, "1\r\n");

      context.current_bit_stream_to_get_here.push_back('1');
      huffman_construct_decompressor(asm_file, context, bag->bag_1);
      context.current_bit_stream_to_get_here.pop_back();

   }
   else
   {
      // If there's no decision, it reports.

      std::vector<char> construct_sequence_string;
      for (unsigned int i = 0; i < context.current_bit_stream_to_get_here.size(); i++)
      {
         construct_sequence_string.push_back(context.current_bit_stream_to_get_here[i]);
      }

      construct_sequence_string.push_back(0);

      std::string sequence_as_string = std::string(&construct_sequence_string[0]);

      unsigned char value = context.map_sequences_to_chars[sequence_as_string] * 16;

      //printf("Looking at %s. Map to %d.\r\n", sequence_as_string.c_str(), value);

      if (value > 0)
      {
         fprintf(asm_file, "    or     $%02X\r\n", (unsigned char)value);
      }

      //fprintf(asm_file, "    jp     %sdecompress_finished_reading_nibble\r\n", asm_token_prefix);
      fprintf(asm_file, "    ret\r\n", asm_token_prefix);
   }
}

void bit_array_append_encoding_string(unsigned char *output_file_data, unsigned int bit, char *s)
{
   unsigned int l = strlen(s);

   for (unsigned int b = 0; b < l; b++)
   {
      unsigned int final_bit = bit + b;

      unsigned int final_byte = final_bit/8;

      unsigned int final_bitmask = (*s == '1')<<(final_bit & 7);

      output_file_data[final_byte] |= final_bitmask;

      s++;
   }
}

void std_vector_char_ToTokenFriendlyFilename(std::vector<char> &t)
{
   for (unsigned int i = 0; i < t.size(); i++)
   {
      if (t[i] == '.') t[i] = '_';
      if (t[i] == ' ') t[i] = '_';
   }
}

std::vector<char> huffman_encode(const unsigned char *data, unsigned int data_size, char encoding_strings[NO_INPUT_ELEMENT_ENTRIES][ENCODING_STRING_MAX_LENGTH])
{
   // Lets count how many bits we need to encode this output array.
   unsigned int total_bit_count = 0;

   // First pass to determine the length of the encoded file.
   // (otherwise I'll be grabbing and putting bits back into the
   // vector and it gets AWFUL.
   for (unsigned int c = 0; c < data_size; c++)
   {
      for (unsigned int nibble = 0; nibble < 2; nibble++)
      {
         // Read each nibble from the input stream in turn.
         unsigned int nibble_read_from_file = (nibble == 0) ? (data[c] & 15) :
                                                              (data[c] >> 4);

         // Remember that the encoding strings start with an 'x' for the global root bag.
         const char *encoding_string_for_this_nibble = encoding_strings[nibble_read_from_file] + 1;

         // Count the number of bits needed
         total_bit_count += strlen(encoding_string_for_this_nibble);
      }
   }

   // We need X bytes...
   unsigned int total_byte_size = (total_bit_count+7) / 8;

   std::vector<char> encoded_data(total_byte_size);
   unsigned char *encoded_data_ptr = (unsigned char *)&encoded_data[0];

   // Holds the absolute complete number of bits written so far.
   unsigned int bit_counter = 0;

   // Second pass to put stuff into the vector
   for (unsigned int c = 0; c < data_size; c++)
   {
      for (unsigned int nibble = 0; nibble < 2; nibble++)
      {
         // Read each nibble from the input stream in turn.
         unsigned int nibble_read_from_file = (nibble == 0) ? (data[c] & 15) :
                                                              (data[c] >> 4);

         // Apply the bits from the encoding string for this nibble into the output vector.

         // Remember that the encoding strings start with an 'x' for the global root bag.
         const char *encoding_string_for_this_nibble = encoding_strings[nibble_read_from_file] + 1;

         unsigned int encoded_length = strlen(encoding_string_for_this_nibble);

         for (unsigned int bit = 0; bit < encoded_length; bit++)
         {
            // Apply bit encoding_string_for_this_nibble[bit] into encoded_data_ptr[bit_counter]

            unsigned char &destination_char = encoded_data_ptr[bit_counter/8];

            unsigned char destination_bit = 1 << (bit_counter & 7);

            if (encoding_string_for_this_nibble[bit] == '1')
            {
               destination_char |= destination_bit;
            }

            bit_counter++;
         }
      }
   }

   return encoded_data;
}

struct EncodedFileInformation
{
   std::string file_token;

   std::vector<char> encoded_file;

   unsigned int input_size;
   unsigned int output_size;
};

void huffman_catalog(int argc, char *argv[])
{
   LoadedFile loaded_catalog_file;

   loaded_catalog_file.load(argv[1]);

   if (!loaded_catalog_file.valid)
   {
      printf("Couldn't load catalog file.\r\n");
      exit(-1);
   }

   HuffmanCatalogFile h;

   if (!HuffmanCatalogFile_fromLoadedFile(loaded_catalog_file, h))
   {
      printf("Couldn't parse catalog file.\r\n");
      exit(-1);
   }

   const char *prefix = h.asm_token_prefix.c_str();

   printf("Catalog file parsing results:\r\n");
   printf("Output asm file filename: %s.\r\n", h.output_asm_file_filename.c_str());
   printf("asm token prefix: %s.\r\n", prefix);
   printf("Compression type: %s.\r\n", h.compression == HuffmanCatalogFile::BYTE ? "Byte" : "Nibble");
   printf("Files to load:\r\n");
   for (unsigned int i = 0; i < h.files_to_load.size(); i++)
   {
      printf("  %s\r\n", h.files_to_load[i].c_str());
   }

   // Alright, we have the catalog file loaded into memory.
   // Let's load each file one by one and populate the membership table.

   unsigned int entry_populations[NO_INPUT_ELEMENT_ENTRIES] = {0};

   for (unsigned int file_row = 0; file_row < h.files_to_load.size(); file_row++)
   {
      LoadedFile loaded_file;

      loaded_file.load(h.files_to_load[file_row].c_str());

      for (unsigned int b = 0; b < loaded_file.data_size; b++)
      {
         unsigned char read_byte = loaded_file.data[b];

         unsigned char l_nibble = read_byte & 15;
         unsigned char h_nibble = read_byte >> 4;

         entry_populations[l_nibble]++;
         entry_populations[h_nibble]++;
      }
   }

   // Now to do the actual Complicated Processing.

   // Create a huffman_bag that holds every element.
   huffman_bag *master_bag = huffman_bag_create();

   for (unsigned int b = 0; b < NO_INPUT_ELEMENT_ENTRIES; b++)
   {
      master_bag->owns_entry[b] = true;
   }

   // Split this huffman_bag....
   huffman_bag_split(master_bag, entry_populations);

   // Construct the encoding strings for each entry.
   char encoding_strings[NO_INPUT_ELEMENT_ENTRIES][ENCODING_STRING_MAX_LENGTH];

   for (unsigned int entry = 0; entry < NO_INPUT_ELEMENT_ENTRIES; entry++)
   {
      // Do a recursive depth first bag search to get the full pathname of each entry
      huffman_bag_return_encoding_string(master_bag, entry, encoding_strings[entry]);
   }

   // Start thinking about outputting stuff to the file:
   FILE *asm_file   = fopen(h.output_asm_file_filename.c_str(),   "wb");
   fprintf(asm_file, ".bank 0\r\n");
   fprintf(asm_file, ".section \"%ssection\"\r\n", prefix);
   fprintf(asm_file, "\r\n");

   unsigned int output_byte_counter = 0;

   std::vector<EncodedFileInformation> encoded_file_informations(h.files_to_load.size());

   for (unsigned int file_row = 0; file_row < h.files_to_load.size(); file_row++)
   {
      EncodedFileInformation &encoded_file_information = encoded_file_informations[file_row];

      LoadedFile loaded_file;

      loaded_file.load(h.files_to_load[file_row].c_str());

      std::vector<char> file_name_vector_char = std_string_to_std_vector_char(h.files_to_load[file_row]);

      std_vector_char_ToTokenFriendlyFilename(file_name_vector_char);

      encoded_file_information.file_token = std::string(&file_name_vector_char[0]);

      fprintf(asm_file, ";'%30s'->'%30s' ", h.files_to_load[file_row].c_str(), &encoded_file_information.file_token[0]);

      encoded_file_information.encoded_file = huffman_encode(loaded_file.data, loaded_file.data_size, encoding_strings);

      encoded_file_information.input_size  = loaded_file.data_size;
      encoded_file_information.output_size = encoded_file_information.encoded_file.size();

      fprintf(asm_file, ";%5d -> %5d ", encoded_file_information.input_size, encoded_file_information.output_size);
      fprintf(asm_file, "\r\n");
   }
   fprintf(asm_file, "\r\n");

   unsigned int total_decoded_bits = 0;
   unsigned int total_encoded_bits = 0;

   for (unsigned int entry = 0; entry < NO_INPUT_ELEMENT_ENTRIES; entry++)
   {
      unsigned int encoding_string_length = strlen(encoding_strings[entry] + 1);

      unsigned int total = entry_populations[entry] * encoding_string_length;

      fprintf(asm_file,
              ";   Entry '%02X': %-20s (%2d). Pop = %4d. Total = %7d.\r\n",
              entry,
              encoding_strings[entry] + 1,
              encoding_string_length,
              entry_populations[entry],
              total);

      total_encoded_bits += total;
      total_decoded_bits += entry_populations[entry] * 4;
   }

   int total_encoded_bytes = (total_encoded_bits+7)/8;
   int total_decoded_bytes = (total_decoded_bits+7)/8;

   int saving_bytes = total_decoded_bytes - total_encoded_bytes;
   double percentage_bytes = ((double)saving_bytes * 100.0) / 32768.0;

   fprintf(asm_file, "; Bits %d to %d. ", total_decoded_bits, total_encoded_bits);
   fprintf(asm_file, "Bytes %d to %d. (%d saved = %2.2f%% of cart)\r\n", total_decoded_bytes, total_encoded_bytes, saving_bytes, percentage_bytes);

   fprintf(asm_file, "\r\n");

   for (unsigned int file_row = 0; file_row < h.files_to_load.size(); file_row++)
   {
      EncodedFileInformation &encoded_file_information = encoded_file_informations[file_row];

      fprintf(asm_file, ".equ %s%s_fullsize = %d\r\n", prefix, encoded_file_information.file_token.c_str(), encoded_file_information.input_size);
   }
   fprintf(asm_file, "\r\n");

   fprintf(asm_file, "; The following indices can be used as offsets into the below table, if you like.\r\n");
   // Write out an enumeration.
   for (unsigned int file_row = 0; file_row < h.files_to_load.size(); file_row++)
   {
      EncodedFileInformation &encoded_file_information = encoded_file_informations[file_row];

      fprintf(asm_file, ".equ %s%-60s = %d\r\n", prefix, encoded_file_information.file_token.c_str(), file_row);
   }
   fprintf(asm_file, "\r\n");
   // Write out a table of offsets.
   fprintf(asm_file, "%sindex:\r\n", prefix);

   for (unsigned int file_row = 0; file_row < h.files_to_load.size(); file_row++)
   {
      EncodedFileInformation &encoded_file_information = encoded_file_informations[file_row];

      fprintf(asm_file, ".dw %s%s_data\r\n", prefix, encoded_file_information.file_token.c_str());
      fprintf(asm_file, ".dw %s%s_fullsize\r\n", prefix, encoded_file_information.file_token.c_str());
   }

   fprintf(asm_file, "\r\n");

   // Write out the decoder.
   fprintf(asm_file, "; Decoder for this archive.\r\n");

   fprintf(asm_file, "; Put pointer to encoded file in HL.\r\n");
   fprintf(asm_file, "; Size of file (or however many bytes you want really) to decode in BC\r\n");
   fprintf(asm_file, "; Destination memory address in DE. $0000 is interpreted as 'OUT' VDP instead.\r\n");
   fprintf(asm_file, "%sdecompress:\r\n", prefix);
   fprintf(asm_file, "    push   bc                                                                 ; Allow the parameters to cross into the shadow dimension.\r\n");
   fprintf(asm_file, "    push   de\r\n");
   fprintf(asm_file, "    exx\r\n");
   fprintf(asm_file, "    pop    de\r\n");
   fprintf(asm_file, "    pop    hl                                                                 ; HL' holds number of remanining bytes.\r\n");
   fprintf(asm_file, "    ld     b,0                                                                ; B' is 'memory write instead' flag.\r\n");
   fprintf(asm_file, "    ld     a,d\r\n");
   fprintf(asm_file, "    or     e\r\n");
   fprintf(asm_file, "    jr     z,+\r\n");
   fprintf(asm_file, "    ld     b,1                                                                ; We're writing to RAM, very important!!\r\n");
   fprintf(asm_file, "+:  exx\r\n");
   fprintf(asm_file, "    xor    a                                                                  ; A holds the in-progress nibble construct. Need a whole buncha zeroes.\r\n");
   fprintf(asm_file, "    ld     c,a                                                                ; C is 'valid bits of huffman stream' counter\r\n");
   fprintf(asm_file, "    ld     e,a                                                                ; E tells us whether we're reading the first or second nibble.\r\n");
   fprintf(asm_file, "%sdecompress_return_to_decompression:                                         ; Jump here when we want to begin decompression and return to 'finished_reading_nibble'\r\n", prefix);
   fprintf(asm_file, "    call   %sdecompress_perform_decompression\r\n", prefix);
   fprintf(asm_file, "%sdecompress_finished_reading_nibble:\r\n", prefix);
   fprintf(asm_file, "    bit    0,e                                                                ; If this is zero, we've just read the first nibble.\r\n");
   fprintf(asm_file, "    jr     nz,%sdecompress_ready_to_output_a_byte\r\n", prefix);
   fprintf(asm_file, "    ; Swap the high nibble into the lowest position\r\n");
   fprintf(asm_file, "    rrca\r\n");
   fprintf(asm_file, "    rrca\r\n");
   fprintf(asm_file, "    rrca\r\n");
   fprintf(asm_file, "    rrca                                                                      ; We're ready to read a new high nibble.\r\n");
   fprintf(asm_file, "    inc    e\r\n");
   fprintf(asm_file, "    jr     %sdecompress_return_to_decompression\r\n", prefix);
   fprintf(asm_file, "%sdecompress_ready_to_output_a_byte:\r\n", prefix);
   fprintf(asm_file, "    ; We've read a high and low nibble, so output this byte.\r\n");
   fprintf(asm_file, "    exx                                                                       ; Check for termination condition\r\n");
   fprintf(asm_file, "    bit    0,b                                                                ; Test for memory writes using B'\r\n");
   fprintf(asm_file, "    jr     nz,+\r\n");
   fprintf(asm_file, "    out    (PORT_VDPData),a                                                   ; Write to OUT.\r\n");
   fprintf(asm_file, "    jr     ++\r\n");
   fprintf(asm_file, "+:  ld     (de),a                                                             ; Write to memory.\r\n");
   fprintf(asm_file, "    inc    de\r\n");
   fprintf(asm_file, "++: dec    hl\r\n");
   fprintf(asm_file, "    ld     a,h\r\n");
   fprintf(asm_file, "    or     l\r\n");
   fprintf(asm_file, "    exx\r\n");
   fprintf(asm_file, "    ret    z                                                                  ; Return when we've reached the end of the data stream.\r\n");
   fprintf(asm_file, "    xor    a                                                                  ; Clear byte under construction.\r\n");
   fprintf(asm_file, "    ld     e,a                                                                ; Reset nibble flag.\r\n");
   fprintf(asm_file, "    jr     %sdecompress_return_to_decompression\r\n", prefix);

   fprintf(asm_file, "%sdecompress_perform_decompression:\r\n", prefix);
   // Now to write the decoder. Erk.

   HuffmanConstructDecompressorContext context;
   context.catalog_file_info = &h;

   for (unsigned int entry = 0; entry < NO_INPUT_ELEMENT_ENTRIES; entry++)
   {
      context.map_sequences_to_chars[std::string(encoding_strings[entry] + 1)] = entry;

      //printf("Map '%s' to %d.\r\n", std::string(encoding_strings[entry] + 1).c_str(), entry);
   }

   huffman_construct_decompressor(asm_file, context, master_bag);
   fprintf(asm_file, "%sdecompress_get_next_bit:\r\n", prefix);
   fprintf(asm_file, "    dec    c\r\n");
   fprintf(asm_file, "    jp     p,+\r\n");
   fprintf(asm_file, "    ; We ran out of bits in the current byte.\r\n");
   fprintf(asm_file, "    ld     c,7\r\n");
   fprintf(asm_file, "    ld     b,(hl)\r\n");
   fprintf(asm_file, "    inc    hl\r\n");
   fprintf(asm_file, "+:  rr     b                                                                  ; Put the next bit of the compressed byte into the carry bit.\r\n");
   fprintf(asm_file, "    ret\r\n");

   fprintf(asm_file, "\r\n");

   // Write out the data.
   for (unsigned int file_row = 0; file_row < h.files_to_load.size(); file_row++)
   {
      EncodedFileInformation &encoded_file_information = encoded_file_informations[file_row];

      fprintf(asm_file, "%s%s_data:\r\n.db ", prefix, encoded_file_information.file_token.c_str());

      for (unsigned int b = 0; b < encoded_file_information.output_size; b++)
      {
         fprintf(asm_file, "$%02X, ", (unsigned char)encoded_file_information.encoded_file[b]);

         if ((b & 15) == 15) fprintf(asm_file, "\r\n.db ");
      }

      fprintf(asm_file, "\r\n");
   }

   fprintf(asm_file, "\r\n");
   fprintf(asm_file, ".ends\r\n");

   fclose(asm_file);

   huffman_bag_destroy(master_bag);
}

void huffman(int argc, char *argv[])
{
   // Read in the file and produce the population table.

   LoadedFile f;

   f.load(argv[2]);

   if (!f.valid)
   {
      printf("Error loading.\r\n");

      exit(-1);
   }

   unsigned int entry_populations[NO_INPUT_ELEMENT_ENTRIES] = {0};

   for (unsigned int b = 0; b < f.data_size; b++)
   {
      unsigned char read_byte = f.data[b];

      unsigned char l_nibble = read_byte & 15;
      unsigned char h_nibble = read_byte >> 4;

      entry_populations[l_nibble]++;
      entry_populations[h_nibble]++;
   }

   // Create a huffman_bag that holds every element.
   huffman_bag *master_bag = huffman_bag_create();

   for (unsigned int b = 0; b < NO_INPUT_ELEMENT_ENTRIES; b++)
   {
      master_bag->owns_entry[b] = true;
   }

   // Split this huffman_bag....
   huffman_bag_split(master_bag, entry_populations);

   char encoding_string[NO_INPUT_ELEMENT_ENTRIES][NO_INPUT_ELEMENT_ENTRIES];

   unsigned int total_size_bits = 0;

   FILE *stats = fopen(argv[4],"wb");

   for (unsigned int entry = 0; entry < NO_INPUT_ELEMENT_ENTRIES; entry++)
   {
      // Do a recursive depth first bag search to get the full pathname of each entry
      huffman_bag_return_encoding_string(master_bag, entry, encoding_string[entry]);

      unsigned int encoding_string_length = strlen(encoding_string[entry] + 1);

      unsigned int total = entry_populations[entry] * encoding_string_length;

      fprintf(stats, "Entry '%02X': %-20s (%2d). Pop = %4d. Total = %7d.\r\n",
              entry,
              encoding_string[entry] + 1,
              encoding_string_length,
              entry_populations[entry],
              total);

      total_size_bits += total;
   }

   unsigned int total_size_bytes = (total_size_bits+7)/8;

   fprintf(stats, "Total = %d bits. %d bytes.\r\n", total_size_bits, total_size_bytes);

   fclose(stats);

   // For every entry in the input file, output their encoded representations
   // to the output file!

   unsigned char *output_file_data = new unsigned char[total_size_bytes];

   for (unsigned int output_byte = 0; output_byte < total_size_bytes; output_byte++)
   {
      output_file_data[output_byte] = 0;
   }

   unsigned int bit = 0;

   for (unsigned int byte_of_input = 0; byte_of_input < f.data_size; byte_of_input++)
   {
      unsigned char entry;
      unsigned int encoding_string_length;

      unsigned char read_byte = f.data[byte_of_input];

      unsigned char l_nibble = read_byte & 15;
      unsigned char h_nibble = read_byte >> 4;

      entry = l_nibble;

      encoding_string_length = strlen(encoding_string[entry] + 1);

      bit_array_append_encoding_string(output_file_data, bit, encoding_string[entry] + 1);

      bit += encoding_string_length;

      entry = h_nibble;

      encoding_string_length = strlen(encoding_string[entry] + 1);

      bit_array_append_encoding_string(output_file_data, bit, encoding_string[entry] + 1);

      bit += encoding_string_length;
   }

   FILE *o = fopen(argv[3],"wb");

   fwrite(output_file_data,total_size_bytes,1,o);

   fclose(o);

   delete[] output_file_data;

   huffman_bag_destroy(master_bag);


   // Output something that'll help me decode that madness.
   printf("Finished normally.\r\n");
}

int main(int argc, char *argv[])
{
   if (argc < 2)
   {
      printf("Usage: 2013huffmanencoder catalog_file.txt\r\n");
      printf("Loads catalog_file.txt and compresses all the files referred within.\r\n");

      exit(-1);
   }

   huffman_catalog(argc, argv);

   return 0;
}
