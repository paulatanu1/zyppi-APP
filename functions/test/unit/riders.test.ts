import { describe, expect, it } from "vitest";
import { ageOn, applicationProblems, payoutSummary, readApplication } from "../../src/riders/model";

const now = new Date(Date.UTC(2026, 10, 14));
const full = (over: Record<string, unknown> = {}) =>
  readApplication(
    {
      fullName: "Raju Mahato",
      phone: "9800011111",
      dob: "1998-05-20",
      address: "Ward 5, Station Road, Purulia",
      serviceAreaId: "a1",
      vehicleType: "bike",
      vehicleNumber: "wb 56 ab 1234",
      drivingLicenceNumber: "WB5620190001234",
      docs: {
        aadhaarFront: "riders/u1/kyc/af.jpg",
        aadhaarBack: "riders/u1/kyc/ab.jpg",
        selfie: "riders/u1/kyc/s.jpg",
        drivingLicence: "riders/u1/kyc/dl.jpg",
        rc: "riders/u1/kyc/rc.jpg",
      },
      payout: { method: "upi", upiId: "raju@okaxis" },
      ...over,
    },
    "u1",
  );

describe("readApplication", () => {
  it("normalises and keeps only the rider's own document paths", () => {
    const a = readApplication(
      { vehicleNumber: " wb 56  ab 1234 ", docs: { selfie: "riders/other/kyc/x.jpg", rc: "riders/u1/kyc/../x" } },
      "u1",
    );
    expect(a.vehicleNumber).toBe("WB 56 AB 1234");
    expect(a.docs).toEqual({});
  });
});

describe("applicationProblems", () => {
  it("accepts a complete bike application", () => {
    expect(applicationProblems(full(), true, now)).toEqual([]);
  });

  it("does not need a licence, RC or vehicle number for a cycle", () => {
    const a = full({ vehicleType: "cycle", vehicleNumber: "", drivingLicenceNumber: "", docs: { aadhaarFront: "riders/u1/kyc/a", aadhaarBack: "riders/u1/kyc/b", selfie: "riders/u1/kyc/s" } });
    expect(applicationProblems(a, true, now)).toEqual([]);
  });

  it("lists what is missing on submit but lets a partial draft through", () => {
    const empty = readApplication({}, "u1");
    expect(applicationProblems(empty, false, now)).toEqual([]);
    expect(applicationProblems(empty, true, now)).toEqual(
      expect.arrayContaining(["Full name is required", "Upload a clear selfie", "Add a UPI ID or bank account for payouts"]),
    );
  });

  it("checks age, formats and bank details", () => {
    const problems = applicationProblems(
      full({ dob: "2010-01-01", phone: "12345", vehicleNumber: "XYZ", payout: { method: "bank", accountName: "Raju", accountNumber: "12ab", ifsc: "sbin1234" } }),
      true,
      now,
    );
    expect(problems).toEqual([
      "Enter a 10-digit Indian mobile number",
      "Riders must be at least 18",
      "Vehicle number looks wrong (e.g. WB 56 AB 1234)",
      "Account number must be 9–18 digits",
      "IFSC looks wrong (e.g. SBIN0001234)",
    ]);
  });
});

describe("helpers", () => {
  it("computes age on a date", () => {
    expect(ageOn("2008-11-15", now)).toBe(17);
    expect(ageOn("2008-11-14", now)).toBe(18);
    expect(ageOn("2001-02-30", now)).toBeNaN();
  });

  it("keeps only the last 4 digits of an account on the main doc", () => {
    expect(payoutSummary({ method: "bank", accountName: "R", accountNumber: "123456789012", ifsc: "SBIN0001234" })).toEqual({
      method: "bank", upiId: null, accountLast4: "9012", ifsc: "SBIN0001234",
    });
  });
});
