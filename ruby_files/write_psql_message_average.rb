class WritePSQLMessageAverage
	attr_accessor :message, :conection, :river

	def initialize(args)
		@connection = args.fetch(:connection)
		@message = args.fetch(:message,'')
		@river = args.fetch(:river)
	end

	# Create name name for table of averaged river discharges 
	def new_table_name
		"#{@river.name.downcase}_#{@river.rcp.downcase}_#{@river.downscale.downcase}_#{@river.hydro.downcase}_mean"		
	end

	# Wriet SQL query header/SELECT statement to instance of message for computing AVG
	def write_psql_head_message_average
		@message = "CREATE TABLE #{new_table_name} AS\n" 
	end

	# Write row-wise averaging of the rivers in the temp table 
	def write_average_discharges
		write_psql_head_message_average
		@message << "SELECT *,\n"
		@message << "       (SELECT AVG(Col)\n"
		@river.gcm_list.each_with_index do |gcm, ii|
			if ii < 1
				@message << "        FROM   (VALUES(sf#{ii}),\n"
			elsif ii >= 1 && ii < @river.gcm_list.length-1
				@message << "                      (sf#{ii}),\n"
			else
				@message << "                      (sf#{ii})) V(Col)) AS q_avg\n"
			end
		end
		@message << "FROM temp;"
	end

	def write_drop_temp_table
		@message = 'DROP TABLE IF EXISTS temp;'
	end

	def write_delete_new_table
		"DROP TABLE IF EXISTS #{new_table_name}"
	end

	def write_success_average_message
		"Successfully added table #{new_table_name}"
	end
end



# CREATE TABLE temp AS 
# SELECT *,
#        (SELECT AVG(Col)
#         FROM   (VALUES(sfl),
#                       (sfr),
#                       (sfm)) V(Col)) AS col_average
# FROM   t4