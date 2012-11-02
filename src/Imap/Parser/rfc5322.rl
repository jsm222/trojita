# Generated by abnfgen at Thu Nov  1 22:36:51 2012
# Output file: rfc5322.rl
# Sources:
# 	core
# 	rfc5322.abnf
%%{
	# write your name
	machine rfc5322;

	# generated rules, define required actions
	ALPHA = 0x41..0x5a | 0x61..0x7a;
	BIT = "0" | "1";
	CHAR = 0x01..0x7f;
	CR = "\r";
	LF = "\n";
	CRLF = CR LF;
	CTL = 0x00..0x1f | 0x7f;
	DIGIT = 0x30..0x39;
	DQUOTE = "\"";
	HEXDIG = DIGIT | "A"i | "B"i | "C"i | "D"i | "E"i | "F"i;
	HTAB = "\t";
	SP = " ";
	WSP = SP | HTAB;
	LWSP = ( WSP | ( CRLF WSP ) )*;
	OCTET = 0x00..0xff;
	VCHAR = 0x21..0x7e;
	obs_NO_WS_CTL = 0x01..0x08 | "\v" | "\f" | 0x0e..0x1f | 0x7f;
	obs_qp = "\\" ( "\0" | obs_NO_WS_CTL | LF | CR );

    # backslash + something, pushing into current string
	quoted_pair = ( ( "\\" ( VCHAR | WSP ) ) | obs_qp ) $push_current_backslashed;

	obs_FWS = ( CRLF? WSP )+;
	FWS = ( ( WSP* CRLF )? WSP+ ) | obs_FWS;
	obs_ctext = obs_NO_WS_CTL;
	ctext = 0x21..0x27 | 0x2a..0x5b | 0x5d..0x7e | obs_ctext;
    # FIXME: nested comments should be supported
	comment = "(" ( FWS? (ctext | quoted_pair) )* FWS? ")";
	ccontent = ctext | quoted_pair | comment;
	CFWS = ( ( FWS? comment )+ FWS? ) | FWS;
	atext = ALPHA | DIGIT | "!" | "#" | "$" | "%" | "&" | "'" | "*" | "+" | "-" | "/" | "=" | "?" | "^" | "_" | "`" | "{" | "|" | "}" | "~";

    # pushing chars
	atom = CFWS? atext+ $push_current_char CFWS?;

    # pushing chars
	dot_atom_text = (atext+ ( "." atext+ )*) $push_current_char;

    # pushing chars
	dot_atom = CFWS? dot_atom_text CFWS?;

	specials = "(" | ")" | "<" | ">" | "[" | "]" | ":" | ";" | "@" | "\\" | "," | "." | DQUOTE;
	obs_qtext = obs_NO_WS_CTL;

    # pushing chars
    qtext = ("!" | 0x23..0x5b | 0x5d..0x7e | obs_qtext) $push_current_char;

    # pushing chars
	qcontent = qtext | quoted_pair;

    # pushing chars
    quoted_string = CFWS? DQUOTE ( ( ( FWS? qcontent )+ FWS? ) | FWS ) DQUOTE CFWS?;
	
    # pushing chars
    word = atom | quoted_string;
    # pushing chars
	obs_phrase = word ( word | "." $push_current_char | CFWS )*;
    # pushing chars
    phrase = (word+ | obs_phrase);
	
    obs_utext = "\0" | obs_NO_WS_CTL | VCHAR;
	obs_unstruct = ( ( CR* ( obs_utext | FWS )+ ) | LF+ )* CR*;
	unstructured = ( ( FWS? VCHAR )* WSP* ) | obs_unstruct;
	day_name = "Mon"i | "Tue"i | "Wed"i | "Thu"i | "Fri"i | "Sat"i | "Sun"i;
	obs_day_of_week = CFWS? day_name CFWS?;
	day_of_week = ( FWS? day_name ) | obs_day_of_week;
	obs_day = CFWS? DIGIT{1,2} CFWS?;
	day = ( FWS? DIGIT{1,2} FWS ) | obs_day;
	month = "Jan"i | "Feb"i | "Mar"i | "Apr"i | "May"i | "Jun"i | "Jul"i | "Aug"i | "Sep"i | "Oct"i | "Nov"i | "Dec"i;
	obs_year = CFWS? DIGIT{2,} CFWS?;
	year = ( FWS DIGIT{4,} FWS ) | obs_year;
	date = day month year;
	obs_hour = CFWS? DIGIT{2} CFWS?;
	hour = DIGIT{2} | obs_hour;
	obs_minute = CFWS? DIGIT{2} CFWS?;
	minute = DIGIT{2} | obs_minute;
	obs_second = CFWS? DIGIT{2} CFWS?;
	second = DIGIT{2} | obs_second;
	time_of_day = hour ":" minute ( ":" second )?;
	obs_zone = "UT"i | "GMT"i | "EST"i | "EDT"i | "CST"i | "CDT"i | "MST"i | "MDT"i | "PST"i | "PDT"i | 0x41..0x49 | 0x4b..0x5a | 0x61..0x69 | 0x6b..0x7a;
	zone = ( FWS ( "+" | "-" ) DIGIT{4} ) | obs_zone;
	time = time_of_day zone;
	date_time = ( day_of_week "," )? date time CFWS?;
	display_name = phrase;

    # pushing chars
	obs_local_part = word ( "." $push_current_char word )*;

    # pushing chars
	local_part = dot_atom | quoted_string | obs_local_part;

    # pushing chars
	obs_dtext = (obs_NO_WS_CTL $push_current_char) | quoted_pair;

    # pushing chars
	dtext = ((0x21..0x5a | 0x5e..0x7e) $push_current_char) | obs_dtext;

    # pushing chars
	domain_literal = CFWS? "[" $push_current_char ( FWS? dtext )* FWS? "]" $push_current_char CFWS?;
    # pushing chars
	obs_domain = atom ( "." atom )*;
    # pushing chars
	domain = dot_atom | domain_literal | obs_domain;

	addr_spec = local_part "@" domain;
	obs_domain_list = ( CFWS | "," )* "@" domain ( "," CFWS? ( "@" domain )? )*;
	obs_route = obs_domain_list ":";
	obs_angle_addr = CFWS? "<" obs_route addr_spec ">" CFWS?;
	angle_addr = ( CFWS? "<" addr_spec ">" CFWS? ) | obs_angle_addr;
	name_addr = display_name? angle_addr;
	mailbox = name_addr | addr_spec;
	obs_mbox_list = ( CFWS? "," )* mailbox ( "," ( mailbox | CFWS )? )*;
	mailbox_list = ( mailbox ( "," mailbox )* ) | obs_mbox_list;
	obs_group_list = ( CFWS? "," )+ CFWS?;
	group_list = mailbox_list | CFWS | obs_group_list;
	group = display_name ":" group_list? ";" CFWS?;
	address = mailbox | group;
	obs_addr_list = ( CFWS? "," )* address ( "," ( address | CFWS )? )*;
	address_list = ( address ( "," address )* ) | obs_addr_list;
	path = angle_addr | ( CFWS? "<" CFWS? ">" CFWS? );
	return = "Return-Path:"i path CRLF;
	received_token = word | angle_addr | addr_spec | domain;
	received = "Received:"i received_token* ";" date_time CRLF;
	trace = return? received+;
	ftext = 0x21..0x39 | 0x3b..0x7e;
	field_name = ftext+;
	optional_field = field_name ":" unstructured CRLF;
	resent_date = "Resent-Date:"i date_time CRLF;
	resent_from = "Resent-From:"i mailbox_list CRLF;
	resent_sender = "Resent-Sender:"i mailbox CRLF;
	resent_to = "Resent-To:"i address_list CRLF;
	resent_cc = "Resent-Cc:"i address_list CRLF;
	resent_bcc = "Resent-Bcc:"i ( address_list | CFWS )? CRLF;

    # pushing chars
	obs_id_left = local_part;

    # pushing chars
	id_left = dot_atom_text | obs_id_left;

    # pushing chars
	no_fold_literal = ("[" $push_current_char) dtext* ("]" $push_current_char);

    # pushing chars
	obs_id_right = domain;

    # pushing chars
    id_right = dot_atom_text | no_fold_literal | obs_id_right;
	
    # gets pushed into a list
    msg_id = CFWS? "<" id_left "@" $push_current_char id_right ">" %push_string_list CFWS?;

	resent_msg_id = "Resent-Message-ID:"i msg_id CRLF;
	orig_date = "Date:"i date_time CRLF;
	hdr_from = "From:"i mailbox_list CRLF;
	sender = "Sender:"i mailbox CRLF;
	reply_to = "Reply-To:"i address_list CRLF;
	hdr_to = "To:"i address_list CRLF;
	cc = "Cc:"i address_list CRLF;
	bcc = "Bcc:"i ( address_list | CFWS )? CRLF;
	message_id = "Message-ID:"i >clear_list msg_id CRLF %got_message_id_header;
	in_reply_to = "In-Reply-To:"i >clear_list msg_id+ CRLF %got_in_reply_to_header;
	references = "References:"i >clear_list msg_id+ (CRLF >got_references_header);
	subject = "Subject:"i unstructured CRLF;
	comments = "Comments:"i unstructured CRLF;
	keywords = "Keywords:"i phrase ( "," phrase )* CRLF;
	fields = ( ( trace optional_field* ) | ( resent_date | resent_from | resent_sender | resent_to | resent_cc | resent_bcc | resent_msg_id )+ )* ( orig_date | hdr_from | sender | reply_to | hdr_to | cc | bcc | message_id | in_reply_to | references | subject | comments | keywords | optional_field )*;
	obs_return = "Return-Path"i WSP* ":" path CRLF;
	obs_received = "Received"i WSP* ":" received_token* CRLF;
	obs_orig_date = "Date"i WSP* ":" date_time CRLF;
	obs_from = "From"i WSP* ":" mailbox_list CRLF;
	obs_sender = "Sender"i WSP* ":" mailbox CRLF;
	obs_reply_to = "Reply-To"i WSP* ":" address_list CRLF;
	obs_to = "To"i WSP* ":" address_list CRLF;
	obs_cc = "Cc"i WSP* ":" address_list CRLF;
	obs_bcc = "Bcc"i WSP* ":" ( address_list | ( ( CFWS? "," )* CFWS? ) ) CRLF;
	obs_message_id = "Message-ID"i WSP* ":" >clear_list msg_id CRLF %got_message_id_header;
	obs_in_reply_to = "In-Reply-To"i WSP* ":" >clear_list ( phrase | msg_id )* CRLF %got_in_reply_to_header;

	obs_references = "References"i WSP* ":" >clear_list 
        # RFC5322 says that phrases shall be ignored
        ( phrase | msg_id >clear_str )*
        CRLF %got_references_header;

	obs_subject = "Subject"i WSP* ":" unstructured CRLF;
	obs_comments = "Comments"i WSP* ":" unstructured CRLF;
	obs_phrase_list = ( phrase | CFWS )? ( "," ( phrase | CFWS )? )*;
	obs_keywords = "Keywords"i WSP* ":" obs_phrase_list CRLF;
	obs_resent_date = "Resent-Date"i WSP* ":" date_time CRLF;
	obs_resent_from = "Resent-From"i WSP* ":" mailbox_list CRLF;
	obs_resent_send = "Resent-Sender"i WSP* ":" mailbox CRLF;
	obs_resent_rply = "Resent-Reply-To"i WSP* ":" address_list CRLF;
	obs_resent_to = "Resent-To"i WSP* ":" address_list CRLF;
	obs_resent_cc = "Resent-Cc"i WSP* ":" address_list CRLF;
	obs_resent_bcc = "Resent-Bcc"i WSP* ":" ( address_list | ( ( CFWS? "," )* CFWS? ) ) CRLF;
	obs_resent_mid = "Resent-Message-ID"i WSP* ":" msg_id CRLF;
	obs_optional = field_name WSP* ":" unstructured CRLF;
	obs_fields = ( obs_return | obs_received | obs_orig_date | obs_from | obs_sender | obs_reply_to | obs_to | obs_cc | obs_bcc | obs_message_id | obs_in_reply_to | obs_references | obs_subject | obs_comments | obs_keywords | obs_resent_date | obs_resent_from | obs_resent_send | obs_resent_rply | obs_resent_to | obs_resent_cc | obs_resent_bcc | obs_resent_mid | obs_optional )*;
	text = 0x01..0x09 | "\v" | "\f" | 0x0e..0x7f;
	obs_body = 0x00..0x7f*;
	body = ( ( text{,998} CRLF )* text{,998} ) | obs_body;
	message = ( fields | obs_fields ) ( CRLF body )?;
}%%
