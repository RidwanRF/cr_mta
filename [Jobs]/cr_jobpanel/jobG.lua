jobNames = {
	[1] = "Bányász",
	[2] = "Favágó",
	[3] = "Roncs szállító",
};

function getJobName(id)
	return id == 0 and "Munkanélküli" or (jobNames[id] or "Hibás munka");
end

function getPaymentMultiplier()
	return 1;
end